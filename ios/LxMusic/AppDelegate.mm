#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTBridge.h>
#import <React/RCTRootView.h>

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  BOOL bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  NSNumber *bundleSize = bundleExists ? @([[[NSFileManager defaultManager] attributesOfItemAtPath:jsBundleURL.path error:nil] fileSize]) : @0;
  NSLog(@"[LXMusic] JS Bundle: %@, exists=%d, size=%@", jsBundleURL.path, bundleExists, bundleSize);

  if (!bundleExists) {
    [self showFallbackWindow:[NSString stringWithFormat:@"JS Bundle 缺失\n%@", jsBundleURL.path]];
    return YES;
  }

  // Listen for JS load events
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidLoad:) name:RCTJavaScriptDidLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidFail:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(rnContentDidAppear:) name:RCTContentDidAppearNotification object:nil];

  // 8s timeout fallback
  AppDelegate *selfRef = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!selfRef->_jsLoaded) {
      [selfRef showFallbackWindow:@"JS 加载超时\n\n可能原因:\n- RNN 未完成初始化\n- registerAppLaunchedListener 未触发\n- JS bundle 内部错误"];
    }
  });

  // RNN v7: create bridge FIRST, then bootstrap
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
  [ReactNativeNavigation bootstrapWithBridge:bridge];

  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  NSLog(@"[LXMusic] ✅ JS bundle loaded");
}

- (void)rnContentDidAppear:(NSNotification *)note {
  NSLog(@"[LXMusic] ✅ RN content appeared! Hiding fallback.");
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_fallbackWindow) {
      self->_fallbackWindow.hidden = YES;
      self->_fallbackWindow = nil;
    }
  });
}

- (void)jsDidFail:(NSNotification *)note {
  _jsLoaded = YES;
  NSError *error = note.userInfo[@"error"];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self showFallbackWindow:[NSString stringWithFormat:@"JS 加载失败\n%@", error.localizedDescription ?: @"未知错误"]];
  });
}

- (void)showFallbackWindow:(NSString *)message {
  if (_fallbackWindow) return;
  _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
  _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];

  UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:_fallbackWindow.bounds];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, _fallbackWindow.bounds.size.width - 40, 600)];
  label.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
  label.font = [UIFont systemFontOfSize:14];
  label.numberOfLines = 0;
  label.text = message;
  [scroll addSubview:label];

  UIViewController *vc = [[UIViewController alloc] init];
  [vc.view addSubview:scroll];
  _fallbackWindow.rootViewController = vc;
  [_fallbackWindow makeKeyAndVisible];
}

#pragma mark - RCTBridgeDelegate

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
}

@end
