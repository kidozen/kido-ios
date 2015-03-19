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
#import "KZService.h"
#import "KZLogging.h"

@interface KZOpenedFromNotificationService : KZBaseService

- (instancetype)initWithEndpoint:(NSString *)endpoint;

- (void) applicationDidOpenWithTrackContext:(NSDictionary *)trackContext;

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

- (void) openedFromNotification:(NSDictionary *)trackContext
{
    if (self.notificationOpenedService == nil) {
        NSString *scheme = [[[self loggingService] serviceUrl] scheme];
        
        NSString *host = [[[self loggingService] serviceUrl] host];
        
        NSString *url = [NSString stringWithFormat:@"%@://%@/notifications/track/open", scheme, host];
        self.notificationOpenedService = [[KZOpenedFromNotificationService alloc] initWithEndpoint:url];
        self.notificationOpenedService.tokenController = self.loggingService.tokenController;
        self.notificationOpenedService.strictSSL = self.loggingService.strictSSL;
    }
    
    [self.notificationOpenedService applicationDidOpenWithTrackContext:trackContext];
}

@end


// Bringing private methods.
@interface KZBaseService ()

- (void)addAuthorizationHeader;

@end


@implementation KZOpenedFromNotificationService

- (instancetype)initWithEndpoint:(NSString *)endpoint
{
    if ((self = [super initWithEndpoint:endpoint andName:nil] )) {
 
    }
    
    return self;
}

- (void) applicationDidOpenWithTrackContext:(NSDictionary *)trackContext
{
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client POST:@"/"
           parameters:trackContext
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               NSLog(@"%@", error);
    }];
}

@end
