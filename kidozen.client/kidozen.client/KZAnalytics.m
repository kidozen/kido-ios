//
//  KZAnalytics.m

#import "KZAnalytics.h"
#import "KZApplication.h"
#import "KZDeviceInfo.h"
#import <UIKit/UIKit.h>
#import "KZEvent.h"
#import "KZClickEvent.h"
#import "KZViewEvent.h"
#import "KZCustomEvent.h"
#import "KZSessionEvent.h"
#import "KZEvents.h"

static NSString *const kStartDate = @"startDate";
static NSString *const kSessionUUID = @"sessionUUID";
static NSString *const kBackgroundDate = @"backgroundDate";

@interface KZAnalytics ()

@property (nonatomic, weak) KZLogging *logging;
@property (nonatomic, strong) KZDeviceInfo *deviceInfo;

@property (nonatomic, copy) NSString *currentSessionUUID;
@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) KZEvents *allEvents;
@property (nonatomic, assign) BOOL uploading;

@end

@implementation KZAnalytics

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithLoggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.logging = logging;
        self.uploading = NO;
        self.deviceInfo = [[KZDeviceInfo alloc] init];
        [self start];
    }
    return self;
}

- (void)tagClick:(NSString *)buttonName
{
    KZClickEvent *clickEvent = [[KZClickEvent alloc] initWithEventValue:buttonName sessionUUID:self.currentSessionUUID];
    [self logEvent:clickEvent];
}

- (void)tagView:(NSString *)viewName
{
    KZViewEvent *viewEvent = [[KZViewEvent alloc] initWithEventValue:viewName sessionUUID:self.currentSessionUUID];
    [self logEvent:viewEvent];
}

- (void)tagSessionWithLength:(NSNumber *)length
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:self.deviceInfo.properties];
    attributes[@"sessionLength"] = length;
    
    KZSessionEvent *sessionEvent = [[KZSessionEvent alloc] initWithAttributes:attributes
                                                                  sessionUUID:self.currentSessionUUID];
    [self logEvent:sessionEvent];
}

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes
{
    KZCustomEvent *customEvent = [[KZCustomEvent alloc] initWithEventName:customEventName attributes:attributes sessionUUID:self.currentSessionUUID];
    [self logEvent:customEvent];
}

- (void) logEvent:(KZEvent *)event
{
    [self.allEvents addEvent:event];
}

- (void)sendEvents
{
    // TODO: Uncomment when we've got the service ready.
    
    self.uploading = YES;
//    [self.logging write:self.allEvents.events
//                message:@""
//              withLevel:LogLevelInfo
//             completion:^(KZResponse *response)
//     {
         self.uploading = NO;
//         if (response.error == nil && response.urlResponse.statusCode < 300)
//         {
             [self reset];
             [self start];
//         } else {
                // we just continue with the current saved events.
    
//          }
//     }];
    
}


- (void) start {
    self.allEvents = [[KZEvents alloc] init];
    
    self.currentSessionUUID = [[NSUUID UUID] UUIDString];
    self.startDate = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}

- (void) willEnterForegroundNotification {
    if (self.uploading == NO) {
        self.startDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kStartDate];
        self.currentSessionUUID = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kSessionUUID];
        NSDate *backgroundDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kBackgroundDate];
        
        // We need to know if we were in the background state more than N seconds.
        if (self.startDate != nil && backgroundDate != nil && [[NSDate date] timeIntervalSinceDate:backgroundDate] > 15) {
            
            NSTimeInterval length = [backgroundDate timeIntervalSinceDate:self.startDate];
            NSAssert(length > 0, @"Session should be greater than zero");
            self.allEvents = [KZEvents eventsFromDisk];
            
            [self tagSessionWithLength:@(length)];
            [self sendEvents];
            
        } else {
            // should resume with the previous events and session.
            [self reset];
        }
    }
}

- (void) didEnterBackground {
    if (self.uploading == NO) {
        [self saveAnalyticsSessionState];
    }
}

- (void) saveAnalyticsSessionState
{
    [self.allEvents save];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.currentSessionUUID forKey:kSessionUUID];
    [userDefaults setValue:self.startDate forKey:kStartDate];
    [userDefaults setValue:[NSDate date] forKey:kBackgroundDate];
    [userDefaults synchronize];
    
}

- (void) reset {
    // remove local file.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kStartDate];
    [userDefaults removeObjectForKey:kSessionUUID];
    [userDefaults removeObjectForKey:kBackgroundDate];
    
    [self.allEvents reset];
}

@end
