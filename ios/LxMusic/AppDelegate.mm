#import "AppDelegate.h"
#import <ReactNativeNavigation.h>
#import <React/RCTBundleURLProvider.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [ReactNativeNavigation bootstrapWithBridge:self launchOptions:launchOptions];
  return YES;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
