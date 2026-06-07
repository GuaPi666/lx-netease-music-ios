#import "CacheModule.h"

@implementation CacheModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getAppCacheSize:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(@(0));
}

RCT_EXPORT_METHOD(clearAppCache:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

@end
