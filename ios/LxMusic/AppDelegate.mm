#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
  NSMutableString *_capturedLog;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _capturedLog = [NSMutableString string];
  [_capturedLog appendString:@"[native] Log started\n"];
  
  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  BOOL bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  long long sz = bundleExists ? [[[NSFileManager defaultManager] attributesOfItemAtPath:jsBundleURL.path error:nil] fileSize] : 0;
  [_capturedLog appendFormat:@"[native] Bundle: %@ (%lld bytes)\n", jsBundleURL.lastPathComponent, sz];

  if (!bundleExists) {
    [self showFallback:[NSString stringWithFormat:@"Bundle missing: %@", jsBundleURL.path]];
    return YES;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidLoad:) name:RCTJavaScriptDidLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidFail:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentAppeared:) name:RCTContentDidAppearNotification object:nil];

  AppDelegate *selfRef = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!selfRef->_jsLoaded) {
      [selfRef showFallback:[NSString stringWithFormat:@"TIMEOUT\n\n%@", _capturedLog]];
    }
  });

  [_capturedLog appendString:@"[native] Creating bridge...\n"];
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  [_capturedLog appendString:[NSString stringWithFormat:@"[native] Bridge: %@\n", bridge ? @"created" : @"NULL"]];
  [_capturedLog appendString:@"[native] Bootstrapping RNN...\n"];
  [ReactNativeNavigation bootstrapWithBridge:bridge];
  [_capturedLog appendString:@"[native] RNN done\n"];
  
  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  [_capturedLog appendString:@"[native] JS loaded!\n"];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_fallbackWindow) self->_fallbackWindow.hidden = YES;
  });
}

- (void)contentAppeared:(NSNotification *)note {
  [_capturedLog appendString:@"[native] Content appeared!\n"];
}

- (void)jsDidFail:(NSNotification *)note {
  _jsLoaded = YES;
  NSError *error = note.userInfo[@"error"];
  [_capturedLog appendFormat:@"[native] JS FAILED: %@\n", error.localizedDescription ?: @"?"];
}

- (void)showFallback:(NSString *)message {
  if (!_fallbackWindow) {
    _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
    _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    _fallbackWindow.rootViewController = [[UIViewController alloc] init];
    [_fallbackWindow makeKeyAndVisible];
  }
  UIScrollView *sv = [[UIScrollView alloc] initWithFrame:_fallbackWindow.bounds];
  sv.alwaysBounceVertical = YES;
  sv.contentSize = CGSizeMake(_fallbackWindow.bounds.size.width, MAX(2000, message.length));
  UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, _fallbackWindow.bounds.size.width - 20, sv.contentSize.height - 40)];
  lbl.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.3 alpha:1.0];
  lbl.font = [UIFont fontWithName:@"Menlo" size:9];
  lbl.numberOfLines = 0;
  lbl.text = message;
  [sv addSubview:lbl];
  [_fallbackWindow.rootViewController.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [_fallbackWindow.rootViewController.view addSubview:sv];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
}

@end
