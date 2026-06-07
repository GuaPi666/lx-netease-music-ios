#import "MusicWidgetModule.h"

@implementation MusicWidgetModule
{
  bool hasListeners;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
  return @[@"widget-play-pause", @"widget-prev", @"widget-next"];
}

- (void)startObserving {
  hasListeners = YES;
}

- (void)stopObserving {
  hasListeners = NO;
}

RCT_EXPORT_METHOD(updateWidget:(NSString *)title artist:(NSString *)artist isPlaying:(BOOL)isPlaying artworkUrl:(NSString *)artworkUrl resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  resolve(nil);
}

@end
