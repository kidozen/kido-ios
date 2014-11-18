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

@interface KZAnalyticsSession()

/**
 *  Will log a session with the corresponding length.
 *  When the events are send, we also need to send the session's length.
 *  It is added by the SDK at that particular moment. No need to call this method
 *
 *  @param length is the amount of seconds the session lasted.
 */
- (void)logSessionWithLength:(NSNumber *)length;

@end

static NSString *const kStartDate = @"startDate";
static NSString *const kSessionUUID = @"sessionUUID";
static NSString *const kBackgroundDate = @"backgroundDate";

static NSUInteger kMaximumSecondsToUpload = 300;

@interface KZAnalyticsUploader()

@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, strong) KZLogging *logging;
@property (nonatomic, strong) KZAnalyticsSession *session;
@property (nonatomic, strong) NSTimer *uploadTimer;

@end

@implementation KZAnalyticsUploader

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.uploadTimer invalidate];
    
}

- (instancetype) initWithSession:(KZAnalyticsSession *)session loggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.uploading = NO;
        self.session = session;
        self.logging = logging;
        self.maximumSecondsToUpload = kMaximumSecondsToUpload;
        [self startTimer];
        
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
            NSLog(@"session events are self.session.events %@", self.session.events);
            
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

- (void) startTimer {

    [self.uploadTimer invalidate];
    self.uploadTimer = [NSTimer scheduledTimerWithTimeInterval:self.maximumSecondsToUpload target:self selector:@selector(sendCurrentEvents) userInfo:nil repeats:NO];
}

- (void)sendCurrentEvents {
    
    if ([self.session hasEvents]) {

        self.uploading = YES;
        __weak KZAnalyticsUploader *safeMe = self;
        
        [self.logging write:self.session.events
                    message:@""
                  withLevel:LogLevelInfo
                 completion:^(KZResponse *response)
         {
             safeMe.uploading = NO;
             
             // If there is no error...
             if (response.error == nil && response.urlResponse.statusCode < 300) {
                 [safeMe.session removeSavedEvents];
                 [safeMe.session removeCurrentEvents];
                 
             }
             
             [safeMe.uploadTimer invalidate];
             [safeMe startTimer];
             
         }];


    } else {
        NSLog(@"No events to send. Will try later.");
        [self.uploadTimer invalidate];
        
        [self startTimer];
    }
    
}

- (void)sendEvents
{
    self.uploading = YES;
    __weak KZAnalyticsUploader *safeMe = self;
    
    [self.logging write:self.session.events
                message:@""
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
    {
        safeMe.uploading = NO;
    
        // if no errors
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

// Removes dates for session length and SessionUUID,
// so that we can start a new session.
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
