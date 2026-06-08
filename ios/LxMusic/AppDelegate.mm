#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>
#import <React/RCTLog.h>

// Intercept RCTLog to capture JS console output
static NSMutableString *_capturedLog = nil;
static void LogInterceptor(RCTLogLevel level, NSString *fileName, NSNumber *lineNumber, NSString *message) {
  if (_capturedLog) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [_capturedLog appendFormat:@"[%@:%@] %@\n", fileName.lastPathComponent ?: @"?", lineNumber ?: @0, message];
    });
  }
}

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _capturedLog = [NSMutableString string];
  RCTSetLogFunction(LogInterceptor);
  [_capturedLog appendString:@"[native] Log capture started\n"];

  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  BOOL bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  long long sz = bundleExists ? [[[NSFileManager defaultManager] attributesOfItemAtPath:jsBundleURL.path error:nil] fileSize] : 0;
  [_capturedLog appendFormat:@"[native] Bundle: %@ (%lld bytes)\n", jsBundleURL.lastPathComponent, sz];

  if (!bundleExists) {
    [self showFallback:[NSString stringWithFormat:@"Bundle missing\n%@", jsBundleURL.path]];
    return YES;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidLoad:) name:RCTJavaScriptDidLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidFail:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rnContentDidAppear:) name:RCTContentDidAppearNotification object:nil];

  AppDelegate *selfRef = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 12 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!selfRef->_jsLoaded) {
      [selfRef showFallback:[NSString stringWithFormat:@"TIMEOUT: JS never loaded\n\n%@", _capturedLog]];
    } else if (!selfRef->_fallbackWindow.hidden) {
      [selfRef showFallback:[NSString stringWithFormat:@"TIMEOUT: JS loaded but no UI\n\n%@", _capturedLog]];
    }
  });

  [_capturedLog appendString:@"[native] Bootstrapping RNN...\n"];
  [ReactNativeNavigation bootstrapWithDelegate:self launchOptions:launchOptions];
  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  [_capturedLog appendString:@"[native] JS loaded\n"];
}

- (void)jsDidFail:(NSNotification *)note {
  _jsLoaded = YES;
  NSError *error = note.userInfo[@"error"];
  [_capturedLog appendFormat:@"[native] JS FAILED: %@\n", error.localizedDescription ?: @"?"];
}

- (void)rnContentDidAppear:(NSNotification *)note {
  [_capturedLog appendString:@"[native] Content appeared\n"];
  dispatch_async(dispatch_get_main_queue(), ^{
    self->_fallbackWindow.hidden = YES;
  });
}

- (void)showFallback:(NSString *)message {
  if (!_fallbackWindow) {
    _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
    _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    UIViewController *vc = [[UIViewController alloc] init];
    _fallbackWindow.rootViewController = vc;
    [_fallbackWindow makeKeyAndVisible];
  }
  UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:_fallbackWindow.bounds];
  scroll.contentSize = CGSizeMake(_fallbackWindow.bounds.size.width, MAX(2000, message.length));
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, _fallbackWindow.bounds.size.width - 20, scroll.contentSize.height - 40)];
  label.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.3 alpha:1.0];
  label.font = [UIFont fontWithName:@"Menlo" size:9];
  label.numberOfLines = 0;
  label.text = message;
  [scroll addSubview:label];
  [_fallbackWindow.rootViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [_fallbackWindow.rootViewController.view addSubview:scroll];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
}

@end
