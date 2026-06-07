#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Verify JS bundle exists before bootstrap
  NSURL *jsBundleURL = [self sourceURLForBridge:nil];
  NSLog(@"[LXMusic] JS Bundle URL: %@", jsBundleURL);
  
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:jsBundleURL.path];
  NSLog(@"[LXMusic] JS Bundle exists: %@", fileExists ? @"YES" : @"NO");
  
  if (!fileExists) {
    NSLog(@"[LXMusic] FATAL: JS bundle not found at %@", jsBundleURL.path);
    // Show an alert so user knows why
    dispatch_async(dispatch_get_main_queue(), ^{
      UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"启动失败" 
        message:[NSString stringWithFormat:@"JS Bundle 未找到:\n%@\n\n请重新安装", jsBundleURL.path]
        preferredStyle:UIAlertControllerStyleAlert];
      [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        exit(1);
      }]];
      UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
      window.rootViewController = [[UIViewController alloc] init];
      [window makeKeyAndVisible];
      [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
    return YES;
  }

  [ReactNativeNavigation bootstrapWithDelegate:self launchOptions:launchOptions];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
  // Always use bundled JS in Release; dev server only in DEBUG
#ifdef DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
