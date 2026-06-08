#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate {
  BOOL _jsLoaded;
  UIWindow *_fallbackWindow;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Check JS bundle first - if missing, show native error
  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  BOOL bundleExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  NSNumber *bundleSize = bundleExists ? @([[[NSFileManager defaultManager] attributesOfItemAtPath:jsBundleURL.path error:nil] fileSize]) : @0;

  NSLog(@"[LXMusic] JS Bundle: %@, exists=%d, size=%@", jsBundleURL.path, bundleExists, bundleSize);

  if (!bundleExists) {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:self.window.bounds];
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"JS Bundle 缺失\n\n路径: %@\n\n请重新安装 IPA", jsBundleURL.path];
    UIViewController *vc = [[UIViewController alloc] init];
    [vc.view addSubview:label];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
  }

  // Listen for JS load success/failure
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidLoad:)
    name:RCTJavaScriptDidLoadNotification
    object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(jsDidFail:)
    name:RCTJavaScriptDidFailToLoadNotification
    object:nil];

  // Bootstrap with fallback timer (5s)
  _jsLoaded = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    if (!self->_jsLoaded) {
      NSLog(@"[LXMusic] JS not loaded after 5s — showing fallback");
      [self showFallbackWindow:@"JS 加载超时\n\n可能原因:\n- JS bundle 内部错误\n- 原生模块缺失\n- RNN 初始化失败"];
    }
  });

  [ReactNativeNavigation bootstrapWithDelegate:self launchOptions:launchOptions];
  return YES;
}

- (void)jsDidLoad:(NSNotification *)note {
  _jsLoaded = YES;
  NSLog(@"[LXMusic] JS bundle loaded successfully");
}

- (void)jsDidFail:(NSNotification *)note {
  _jsLoaded = YES;
  NSError *error = note.userInfo[@"error"];
  NSString *msg = [NSString stringWithFormat:@"JS 加载失败\n\n%@", error.localizedDescription ?: @"未知错误"];
  NSLog(@"[LXMusic] JS load failed: %@", error);
  dispatch_async(dispatch_get_main_queue(), ^{
    [self showFallbackWindow:msg];
  });
}

- (void)showFallbackWindow:(NSString *)message {
  if (_fallbackWindow) return;
  _fallbackWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  _fallbackWindow.windowLevel = UIWindowLevelAlert + 1;
  _fallbackWindow.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, _fallbackWindow.bounds.size.width - 40, _fallbackWindow.bounds.size.height - 160)];
  label.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
  label.font = [UIFont systemFontOfSize:15];
  label.numberOfLines = 0;
  label.textAlignment = NSTextAlignmentCenter;
  label.text = message;
  UIViewController *vc = [[UIViewController alloc] init];
  [vc.view addSubview:label];
  _fallbackWindow.rootViewController = vc;
  [_fallbackWindow makeKeyAndVisible];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#ifdef DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
