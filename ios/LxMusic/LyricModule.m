#import "LyricModule.h"

@implementation LyricModule
{
  bool hasListeners;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[@"set-position", @"lyric-line-play", @"set-lock"];
}

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

RCT_EXPORT_METHOD(setSendLyricTextEvent:(BOOL)isSend resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(showDesktopLyric:(NSDictionary *)params resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(hideDesktopLyric:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(play:(nonnull NSNumber *)time resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(pause:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setLyric:(NSString *)lyric translation:(NSString *)translation romalrc:(NSString *)romalrc resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setPlaybackRate:(nonnull NSNumber *)rate resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(toggleTranslation:(BOOL)isShow resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(toggleRoma:(BOOL)isShow resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(toggleLock:(BOOL)isLock resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setColor:(NSString *)unplayColor playedColor:(NSString *)playedColor shadowColor:(NSString *)shadowColor resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setAlpha:(nonnull NSNumber *)alpha resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setTextSize:(nonnull NSNumber *)size resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setShowToggleAnima:(BOOL)show resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setSingleLine:(BOOL)singleLine resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setPosition:(nonnull NSNumber *)x y:(nonnull NSNumber *)y resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setMaxLineNum:(nonnull NSNumber *)maxLineNum resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setWidth:(nonnull NSNumber *)width resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(setLyricTextPosition:(NSString *)textX textY:(NSString *)textY resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(checkOverlayPermission:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

RCT_EXPORT_METHOD(openOverlayPermissionActivity:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@(NO));
}

@end
