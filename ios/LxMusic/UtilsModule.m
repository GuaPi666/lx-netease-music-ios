#import "UtilsModule.h"
#import <UIKit/UIKit.h>

@implementation UtilsModule
{
  bool hasListeners;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[@"screen-state", @"media-volume-changed", @"screen-size-changed"];
}

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

RCT_EXPORT_METHOD(exitApp) {
  dispatch_async(dispatch_get_main_queue(), ^{
    exit(0);
  });
}

RCT_EXPORT_METHOD(getSupportedAbis:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@[@"arm64"]);
}

RCT_EXPORT_METHOD(installApk:(NSString *)filePath fileProviderAuthority:(NSString *)authority resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError *error = [NSError errorWithDomain:@"com.lxmusic.ios" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"installApk not available on iOS"}];
  reject(@"NOT_AVAILABLE", @"installApk not available on iOS", error);
}

RCT_EXPORT_METHOD(screenkeepAwake) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
  });
}

RCT_EXPORT_METHOD(screenUnkeepAwake) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
  });
}

RCT_EXPORT_METHOD(getWIFIIPV4Address:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@"127.0.0.1");
}

RCT_EXPORT_METHOD(getDeviceName:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve([[UIDevice currentDevice] name] ?: @"iPhone");
}

RCT_EXPORT_METHOD(isNotificationsEnabled:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
    resolve(@(settings.authorizationStatus == UNAuthorizationStatusAuthorized));
  }];
}

RCT_EXPORT_METHOD(openNotificationPermissionActivity:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  // iOS doesn't have a direct way to open notification settings programmatically
  // We can open app settings
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
  if ([[UIApplication sharedApplication] canOpenURL:url]) {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
      resolve(@(success));
    }];
  } else {
    resolve(@(NO));
  }
}

RCT_EXPORT_METHOD(requestNotificationPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError *error) {
    if (error) {
      reject(@"PERMISSION_ERROR", @"Failed to request notification permission", error);
    } else {
      resolve(@(granted));
    }
  }];
}

RCT_EXPORT_METHOD(shareText:(NSString *)shareTitle title:(NSString *)title text:(NSString *)text resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (controller.popoverPresentationController) {
      controller.popoverPresentationController.sourceView = rootVC.view;
    }
    [rootVC presentViewController:controller animated:YES completion:nil];
    resolve(@(YES));
  });
}

RCT_EXPORT_METHOD(getSystemLocales:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *locale = [[NSLocale preferredLanguages] firstObject] ?: @"zh-CN";
  resolve(locale);
}

RCT_EXPORT_METHOD(listenWindowSizeChanged) {
  // Event-based; iOS sends through supportedEvents
}

RCT_EXPORT_METHOD(getWindowSize:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  dispatch_async(dispatch_get_main_queue(), ^{
    CGSize size = [UIScreen mainScreen].bounds.size;
    resolve(@{@"width": @(size.width), @"height": @(size.height)});
  });
}

RCT_EXPORT_METHOD(isIgnoringBatteryOptimization:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@(YES));
}

RCT_EXPORT_METHOD(requestIgnoreBatteryOptimization:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@(YES));
}

RCT_EXPORT_METHOD(getUiMode:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  BOOL isDark = NO;
  if (@available(iOS 13.0, *)) {
    isDark = [UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark;
  }
  // 0 = light, 1 = dark (or corresponding Android values)
  resolve(@(isDark ? 2 : 1));
}

RCT_EXPORT_METHOD(adjustSystemMediaVolume:(NSString *)direction resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@(YES));
}

@end
