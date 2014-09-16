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

static NSString *const kStartDate = @"startDate";
static NSString *const kSessionUUID = @"sessionUUID";
static NSString *const kBackgroundDate = @"backgroundDate";

@interface KZAnalytics ()

@property (nonatomic, weak) KZLogging *logging;
@property (nonatomic, strong) KZDeviceInfo *deviceInfo;

@property (nonatomic, copy) NSString *currentSessionUUID;
@property (nonatomic, strong) NSDate *startDate;

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

- (void)tagSession
{
    KZSessionEvent *sessionEvent = [[KZSessionEvent alloc] initWithAttributes:self.deviceInfo.properties
                                                                  sessionUUID:self.currentSessionUUID];
    [self logEvent:sessionEvent];
}

- (void) logEvent:(KZEvent *)event
{
    [self.logging write:[event serializedEvent]
                message:@""
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
     {
         // TODO: Handle response.
         // Enqueue in case there was a failure.
     }];
}


- (void) start {
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
    self.startDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kStartDate];
    self.currentSessionUUID = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kSessionUUID];
    NSDate *backgroundDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kBackgroundDate];

    if (self.startDate != nil && backgroundDate != nil && [[NSDate date] timeIntervalSinceDate:backgroundDate] > 15) {
        // get the persisted events.
        
        NSTimeInterval length = [backgroundDate timeIntervalSinceDate:self.startDate];
        NSAssert(length > 0, @"Session should be greater than zero");
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.deviceInfo.properties];
        params[@"sessionLength"] = @(length);
        params[@"sessionUUID"] = self.currentSessionUUID;
        
        [self tagEvent:@"user-session" attributes:params];
        
        // restart.
        [self reset];
        [self start];
        
    } else {
        [self reset];
    }
}

- (void) didEnterBackground {
    NSLog(@"didEnterBackground");

    [self saveAnalyticsSessionState];
}

- (void) saveAnalyticsSessionState
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:self.currentSessionUUID forKey:kSessionUUID];
    [userDefaults setValue:self.startDate forKey:kStartDate];
    [userDefaults setValue:[NSDate date] forKey:kBackgroundDate];
    [userDefaults synchronize];
    
}

- (void) reset {
    // resume... do nothing.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kStartDate];
    [userDefaults removeObjectForKey:kSessionUUID];
    [userDefaults removeObjectForKey:kBackgroundDate];
}

@end
