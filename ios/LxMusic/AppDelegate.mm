#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>

// MINIMAL TEST: Create RCTBridge directly, bypass RNN entirely
// Verify JS engine boots and console.error works

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
  NSMutableString *_capturedLog;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _capturedLog = [NSMutableString string];
  [_capturedLog appendString:@"[native] Log started\n"];

  NSURL *bundleURL = [self sourceURLForBridge:nil];
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:bundleURL.path];
  long long sz = exists ? [[[NSFileManager defaultManager] attributesOfItemAtPath:bundleURL.path error:nil] fileSize] : 0;
  [_capturedLog appendFormat:@"[native] Bundle @ %@\n", bundleURL.path];
  [_capturedLog appendFormat:@"[native] Exists=%d, size=%lld\n", exists, sz];

  if (!exists) {
    [self showFallback:[NSString stringWithFormat:@"Bundle missing\n%@", bundleURL.path]];
    return YES;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidLoad:) name:RCTJavaScriptDidLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsDidFail:) name:RCTJavaScriptDidFailToLoadNotification object:nil];

  AppDelegate *selfRef = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!selfRef->_jsLoaded) {
      [selfRef showFallback:[NSString stringWithFormat:@"TIMEOUT\n\n%@", _capturedLog]];
    }
  });

  // Create bridge (auto-loads JS on background thread)
  [_capturedLog appendString:@"[native] Creating bridge...\n"];
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  [_capturedLog appendFormat:@"[native] Bridge: %@\n", bridge];
  [_capturedLog appendString:@"[native] Waiting for JS to load...\n"];

  // Also show a base window so we're a proper app
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = [UIColor blackColor];
  UIViewController *vc = [[UIViewController alloc] init];
  vc.view.backgroundColor = [UIColor blackColor];
  self.window.rootViewController = vc;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  [_capturedLog appendString:@"[native] ✅ JS loaded!\n"];
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
  [_capturedLog appendFormat:@"[native] ❌ JS FAILED: %@\n", error.localizedDescription ?: @"?"];
}

- (void)showFallback:(NSString *)msg {
  if (_fallbackWindow) return;
  _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
  _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  UIScrollView *sv = [[UIScrollView alloc] initWithFrame:_fallbackWindow.bounds];
  sv.alwaysBounceVertical = YES;
  sv.contentSize = CGSizeMake(_fallbackWindow.bounds.size.width, 3000);
  UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, _fallbackWindow.bounds.size.width - 20, 2960)];
  l.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.3 alpha:1.0];
  l.font = [UIFont fontWithName:@"Menlo" size:9];
  l.numberOfLines = 0;
  l.text = msg;
  [sv addSubview:l];
  _fallbackWindow.rootViewController = [[UIViewController alloc] init];
  [_fallbackWindow.rootViewController.view addSubview:sv];
  [_fallbackWindow makeKeyAndVisible];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  NSURL *url = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
  [_capturedLog appendFormat:@"[native] sourceURLForBridge called → %@\n", url];
  return url;
}

@end
