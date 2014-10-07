//
//  KZAnalytics.h
//

#import "KZObject.h"

@class KZLogging;

@interface KZAnalytics : KZObject

- (instancetype)initWithLoggingService:(KZLogging *)loggingService;

// By Default, analytics are disabled.
- (void)enableAnalytics:(BOOL)enable;

// this method will erase all current and saved analytics and
// start over.
- (void)resetAnalytics;


- (void)tagClick:(NSString *)buttonName;
- (void)tagView:(NSString *)viewName;

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;


// This property tells us how much time the app needs to be in the background
// so that, when it comes to foreground, a new session is considered or not.
@property (nonatomic, assign) NSUInteger sessionSecondsTimeOut;

// This is the maximum amount of seconds until we upload events.
@property (nonatomic, assign) NSUInteger uploadMaxSecondsThreshold;

@end
