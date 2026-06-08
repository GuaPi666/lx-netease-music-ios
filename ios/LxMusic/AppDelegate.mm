#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 1. Check JS bundle exists
  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  BOOL bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  NSLog(@"[LXMusic] JS Bundle: %@, exists=%d", jsBundleURL.path, bundleExists);

  if (!bundleExists) {
    [self showFallbackWindow:[NSString stringWithFormat:@"JS Bundle 缺失\n%@", jsBundleURL.path]];
    return YES;
  }

  // 2. Monitor JS load
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidLoad:) name:RCTJavaScriptDidLoadNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidFail:) name:RCTJavaScriptDidFailToLoadNotification object:nil];

  // 3. Timeout fallback (8s)
  AppDelegate *selfRef = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!selfRef->_jsLoaded) {
      [selfRef showFallbackWindow:@"JS 加载超时\n\n可能原因:\n- 原生模块缺失\n- RNN 初始化失败\n- JS bundle 内部错误"];
    }
  });

  // 4. Bootstrap RNN (using deprecated API — the only one available in RNN v7)
  [ReactNativeNavigation bootstrapWithDelegate:self launchOptions:launchOptions];

  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  NSLog(@"[LXMusic] ✅ JS bundle loaded successfully");
}

- (void)jsDidFail:(NSNotification *)note {
  _jsLoaded = YES;
  NSError *error = note.userInfo[@"error"];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self showFallbackWindow:[NSString stringWithFormat:@"JS 加载失败\n%@", error.localizedDescription ?: @"未知"]];
  });
}

- (void)showFallbackWindow:(NSString *)message {
  if (_fallbackWindow) return;
  _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
  _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];

  UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:_fallbackWindow.bounds];
  scroll.contentSize = CGSizeMake(_fallbackWindow.bounds.size.width, 2000);

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, _fallbackWindow.bounds.size.width - 40, 400)];
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
