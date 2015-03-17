//
//  KZAnalytics.m

#import "KZAnalytics.h"
#import "KZApplication.h"
#import "KZEvent.h"
#import "KZClickEvent.h"
#import "KZViewEvent.h"
#import "KZCustomEvent.h"
#import "KZSessionEvent.h"
#import "KZAnalyticsSession.h"
#import "KZAnalyticsUploader.h"
#import "KZDeviceInfo.h"


@interface KZOpenedFromNotificationService : KZBaseService

- (void) applicationDidOpenWithNotificationId:(NSString *)notificationId;

@end




@interface KZAnalytics ()

@property (nonatomic, strong) KZAnalyticsSession *session;
@property (nonatomic, strong) KZLogging *loggingService;
@property (nonatomic, strong) KZAnalyticsUploader *sessionUploader;
@property (nonatomic, strong) KZOpenedFromNotificationService *notificationOpenedService;

@end


@implementation KZAnalytics

- (instancetype)initWithLoggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.loggingService = logging;
    }
    return self;
}

- (void)enableAnalytics:(BOOL)enable {
    if (enable == YES) {
        self.session = [[KZAnalyticsSession alloc] initWithUserId:self.userId];
        
        self.sessionUploader = [[KZAnalyticsUploader alloc] initWithSession:self.session
                                                             loggingService:self.loggingService];
        [[KZDeviceInfo sharedDeviceInfo] enableGeoLocation];
        
    } else {
        self.sessionUploader = nil;
    }
}

- (void)resetAnalytics {
    [self.session removeSavedEvents];
    [self.session removeCurrentEvents];
    [self.session startNewSession];
}

- (void)setSessionSecondsTimeOut:(NSUInteger)sessionSecondsTimeOut {
    self.session.sessionTimeout = sessionSecondsTimeOut;
}

- (NSUInteger) sessionSecondsTimeOut {
    return self.session.sessionTimeout;
}

- (void)setUploadMaxSecondsThreshold:(NSUInteger)uploadMaxSecondsThreshold {
    self.sessionUploader.maximumSecondsToUpload = uploadMaxSecondsThreshold;
}

- (NSUInteger)uploadMaxSecondsThreshold {
    return self.sessionUploader.maximumSecondsToUpload;
}

- (NSNumber *)elapsedTimeSinceStart {
    
    NSTimeInterval interval = [NSDate date].timeIntervalSince1970 - self.session.startSessionDate.timeIntervalSince1970;
    
    // Just in case...
    if (interval > 0) {
        return @(interval);
    } else {
        return @(0);
    }
}

- (void)tagClick:(NSString *)buttonName
{
    
    KZClickEvent *clickEvent = [[KZClickEvent alloc] initWithEventValue:buttonName
                                                            sessionUUID:self.session.sessionUUID
                                                                 userId:self.userId
                                                            timeElapsed:[self elapsedTimeSinceStart]];
    [self.session logEvent:clickEvent];
}

- (void)tagView:(NSString *)viewName
{
    KZViewEvent *viewEvent = [[KZViewEvent alloc] initWithEventValue:viewName
                                                         sessionUUID:self.session.sessionUUID
                                                              userId:self.userId
                                                         timeElapsed:[self elapsedTimeSinceStart]];
    [self.session logEvent:viewEvent];
}


- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes
{
    KZCustomEvent *customEvent = [[KZCustomEvent alloc] initWithEventName:customEventName
                                                               attributes:attributes
                                                              sessionUUID:self.session.sessionUUID
                                                                   userId:self.userId
                                                              timeElapsed:[self elapsedTimeSinceStart]];
    [self.session logEvent:customEvent];

}

- (void) openedFromNotification:(NSString *)notificationId
{
    
    if (self.notificationOpenedService == nil) {
        self.notificationOpenedService = [[KZOpenedFromNotificationService alloc] init];
    }
    
    [self.notificationOpenedService applicationDidOpenWithNotificationId:notificationId];
}

@end


// Bringing private methods.
@interface KZBaseService ()

- (void)addAuthorizationHeader;

@end


@implementation KZOpenedFromNotificationService

- (instancetype)init
{
    if ((self = [super initWithEndpoint:@"/notification" andName:nil] )) {
 
    }
    
    return self;
}

- (void) applicationDidOpenWithNotificationId:(NSString *)notificationId {

    NSString *endPoint = [NSString stringWithFormat:@"/%@/ios/opened", notificationId];
    
    [self addAuthorizationHeader];
    
    [self.client POST:endPoint
           parameters:nil 
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
        
    }];
}

@end
