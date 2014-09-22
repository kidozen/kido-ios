//
//  KZAnalyticsUploader.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/18/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZAnalyticsUploader.h"
#import <UIKit/UIKit.h>
#import "KZAnalyticsSession.h"
#import "KZSessionEvent.h"
#import "KZLogging.h"

static NSString *const kStartDate = @"startDate";
static NSString *const kSessionUUID = @"sessionUUID";
static NSString *const kBackgroundDate = @"backgroundDate";

@interface KZAnalyticsUploader()

@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, strong) KZLogging *logging;
@property (nonatomic, strong) KZAnalyticsSession *session;

@end

@implementation KZAnalyticsUploader

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype) initWithSession:(KZAnalyticsSession *)session loggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.uploading = NO;
        self.session = session;
        self.logging = logging;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForegroundNotification)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
    }
    return self;
}


- (void) willEnterForegroundNotification {
    if (self.uploading == NO) {
        [self uploadEvents];
    }
}

- (void) uploadEvents
{
    NSDate *savedStartDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kStartDate];
    NSDate *backgroundDate = (NSDate *)[[NSUserDefaults standardUserDefaults] valueForKey:kBackgroundDate];
    
    // We need to check if the time the app was in the background state
    // is larger than the sessionTimeout
    if ([self.session shouldUploadSessionUsingBackgroundDate:backgroundDate]) {
        
        NSTimeInterval length = [backgroundDate timeIntervalSinceDate:savedStartDate];
        NSAssert(length > 0, @"Session should be greater than zero");
        
        // We only consider valid length values.
        if (length > 0) {
            [self.session loadEventsFromDisk];
            [self.session logSessionWithLength:@(length)];
            [self sendEvents];
        } else {
            [self.session removeSavedEvents];
            [self resetSessionState];
        }
        
    } else {
        // should resume with the previous events and session.
        // We only need to remove the date when we enter to background state.
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBackgroundDate];

    }
}

- (void)sendEvents
{
    // TODO: Uncomment when we've got the service ready.
    NSLog(@"Events to send are :%@", self.session.events);

    self.uploading = YES;
    __weak KZAnalyticsUploader *safeMe = self;
    
    [self.logging write:self.session.events
                message:@""
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
    {
        safeMe.uploading = NO;
        
        if (response.error == nil && response.urlResponse.statusCode < 300) {
            [safeMe.session removeSavedEvents];
        }
        
        [safeMe resetSessionState];
     }];
}


- (void) saveAnalyticsSessionState {
    
    [self.session save];
    NSAssert(self.session.startSessionDate!=nil, @"Start session date is nil");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:self.session.sessionUUID forKey:kSessionUUID];
    [userDefaults setValue:self.session.startSessionDate forKey:kStartDate];
    [userDefaults setValue:[NSDate date] forKey:kBackgroundDate];
    [userDefaults synchronize];
    
}

// removeDatesAndSession
- (void) resetSessionState {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kStartDate];
    [userDefaults removeObjectForKey:kSessionUUID];
    [userDefaults removeObjectForKey:kBackgroundDate];

    [self.session startNewSession];
}

- (void) didEnterBackground {
    if (self.uploading == NO) {
        [self saveAnalyticsSessionState];
    }
}

@end
