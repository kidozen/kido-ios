//
//  KZAnalytics.h
//

#import "KZObject.h"

@class KZLogging;

@interface KZAnalytics : KZObject

// This property tells us how much time the app needs to be in the background
// so that, when it comes to foreground, a new session is considered or not.
@property (nonatomic, assign) NSUInteger sessionTimeOut;

- (instancetype)initWithLoggingService:(KZLogging *)loggingService;

- (void)tagClick:(NSString *)buttonName;
- (void)tagView:(NSString *)viewName;

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;

@end
