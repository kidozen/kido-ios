//
//  KZAnalytics.m

#import "KZAnalytics.h"
#import "KZApplication.h"
#import "KZDeviceInfo.h"
#import <UIKit/UIKit.h>


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
    [self tagEvent:@"Clicked" value:buttonName];
}

- (void)tagView:(NSString *)viewName
{
    [self tagEvent:@"Views" value:viewName];
}

- (void)tagSession
{
    [self tagEvent:@"user-session" attributes:self.deviceInfo.properties];
}

- (void) tagEvent:(NSString *)customEventName attributes:(NSDictionary *)attributes
{
    NSDictionary *params;
    
    if (attributes != nil) {
        params = @{@"eventName" : customEventName,
                   @"eventAttr" : attributes};
    } else {
        params = @{@"eventName" : customEventName};
    }
    
    [self logWithParameters:params];
    
}

- (void) tagEvent:(NSString*)eventName value:(NSString *)eventValue
{
    NSDictionary *params = @{@"eventName" : eventName,
                             @"eventValue" : eventValue};
 
    [self logWithParameters:params];
}


- (void) logWithParameters:(NSDictionary *)params
{
    [self.logging write:params
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
    NSLog(@"UIApplicationWillEnterForegroundNotification");
    self.startDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kStartDate];
    self.currentSessionUUID = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kSessionUUID];
    NSDate *backgroundDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kBackgroundDate];

    if (self.startDate != nil && backgroundDate != nil && [[NSDate date] timeIntervalSinceDate:backgroundDate] > 15) {
        // send data.
        NSLog(@"Sending data");
        NSTimeInterval length = [backgroundDate timeIntervalSinceDate:self.startDate];
        NSAssert(length > 0, @"Session should be greater than zero");
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.deviceInfo.properties];
        params[@"length"] = @(length);
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
