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

@interface KZAnalytics ()

@property (nonatomic, strong) KZAnalyticsSession *session;
@property (nonatomic, strong) KZLogging *loggingService;
@property (nonatomic, strong) KZAnalyticsUploader *sessionUploader;

@end

@implementation KZAnalytics

- (instancetype)initWithLoggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.session = [[KZAnalyticsSession alloc] init];
        self.loggingService = logging;
    }
    return self;
}

- (void)enableAnalytics:(BOOL)enable {
    if (enable == YES) {
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

- (void)tagClick:(NSString *)buttonName
{
    KZClickEvent *clickEvent = [[KZClickEvent alloc] initWithEventValue:buttonName
                                                            sessionUUID:self.session.sessionUUID];
    [self.session logEvent:clickEvent];
}

- (void)tagView:(NSString *)viewName
{
    KZViewEvent *viewEvent = [[KZViewEvent alloc] initWithEventValue:viewName
                                                         sessionUUID:self.session.sessionUUID];
    [self.session logEvent:viewEvent];
}


- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes
{
    KZCustomEvent *customEvent = [[KZCustomEvent alloc] initWithEventName:customEventName
                                                               attributes:attributes
                                                              sessionUUID:self.session.sessionUUID];
    [self.session logEvent:customEvent];

}

@end
