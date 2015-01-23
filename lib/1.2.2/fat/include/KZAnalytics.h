//
//  KZAnalytics.h
//

#import "KZObject.h"

@class KZLogging;
@class KZAnalyticsSession;

@interface KZAnalytics : NSObject

@property (nonatomic, readonly) KZAnalyticsSession *session;

- (instancetype)initWithLoggingService:(KZLogging *)loggingService;

/**
 *  By Default, analytics are disabled.
 *
 *  @param enable should be YES if you want to enable the service, NO otherwise.
 */

- (void)enableAnalytics:(BOOL)enable;

/**
 *  This method will erase all current and saved analytics and start over
 */
- (void)resetAnalytics;

/**
 *  Tags a click with the corresponding name. It'll be reflected in your server.
 *
 *  @param buttonName The name of the button you just clicked/tapped.
 */
- (void)tagClick:(NSString *)buttonName;

/**
 *  Tags a view with the corresponding name.
 *
 *  @param viewName should be something that identifies a particular view.
 */
- (void)tagView:(NSString *)viewName;


/**
 *  Tags a custom event, created by the developer. For example, it could be something 
 *  like "taskCreated".
 *
 *  @param customEventName is the name that identifies the event.
 *  @param attributes      is a dictionary with attributes that corresponds to the event, 
 *                         for example, @{"Category" : "Critical"}
 */
- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;

/**
 *  This property tells us how much time the app needs to be in the background
 *  so that, when it comes to foreground, a new session is considered or not.
 */
@property (nonatomic, assign) NSUInteger sessionSecondsTimeOut;

/**
 *  This is the maximum amount of seconds until we upload events.
 *
 *  If the user of your application is using it for a long time, this property
 *  tells the application the maximum amount of seconds until it uploads all events.
 *  This is to prevent uploading a lot of events at once.
 */
@property (nonatomic, assign) NSUInteger uploadMaxSecondsThreshold;

@end
