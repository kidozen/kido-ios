//
//  KZAnalytics.h
//

#import "KZObject.h"

@class KZLogging;

@interface KZAnalytics : KZObject

- (instancetype)initWithLoggingService:(KZLogging *)loggingService;

- (void)tagEvent:(NSString *)event;

- (void)tagEvent:(NSString *)event
      attributes:(NSDictionary *)attributes;

- (void)tagScreen:(NSString *)screen;

@end
