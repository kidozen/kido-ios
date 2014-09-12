//
//  KZAnalytics.h
//

#import "KZObject.h"

@class KZLogging;

@interface KZAnalytics : KZObject

- (instancetype)initWithLoggingService:(KZLogging *)loggingService;

- (void)tagClick:(NSString *)buttonName;
- (void)tagView:(NSString *)viewName;

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;

@end
