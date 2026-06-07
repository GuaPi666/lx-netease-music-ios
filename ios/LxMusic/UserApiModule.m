#import "UserApiModule.h"

@implementation UserApiModule
{
  bool hasListeners;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[@"api-action"];
}

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

RCT_EXPORT_METHOD(loadScript:(NSDictionary *)info) {
  // Stub: script loading is not supported on iOS
}

RCT_EXPORT_METHOD(sendAction:(NSString *)action data:(NSString *)data) {
  // Stub
}

RCT_EXPORT_METHOD(destroy) {
  // Stub
}

@end
