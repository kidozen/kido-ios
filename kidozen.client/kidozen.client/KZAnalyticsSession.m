//
//  KZAnalyticsSession.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/18/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZAnalyticsSession.h"
#import "KZEvent.h"
#import "KZEvents.h"
#import "KZDeviceInfo.h"
#import "KZSessionEvent.h"
#import "KZInitialSessionEvent.h"

static int kDefaultSessionTimeout = 5;

@interface KZAnalyticsSession()

@property (nonatomic, strong) KZEvents *allEvents;
@property (nonatomic, readwrite, copy) NSString *sessionUUID;
@property (nonatomic, strong) NSDate *startSessionDate;
@property (nonatomic, strong) KZDeviceInfo *deviceInfo;
@property (nonatomic, strong) NSMutableDictionary *sessionAttributes;

@end


@implementation KZAnalyticsSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.deviceInfo = [KZDeviceInfo sharedDeviceInfo];
        self.sessionAttributes = [[NSMutableDictionary alloc] init];
        self.sessionTimeout = kDefaultSessionTimeout;
        [self startNewSession];
        
        self.startSessionDate = [NSDate date];
        

        

    }
    return self;
}


- (void)logEvent:(KZEvent *)event {
    [self.allEvents addEvent:event];
}

- (void)save {
    [self.allEvents save];
}

- (void)removeSavedEvents {
    [self.allEvents removeSavedEvents];
}

- (void)removeCurrentEvents {
    [self.allEvents removeCurrentEvents];
    
}
- (void)startNewSession {
    
    self.allEvents = [[KZEvents alloc] init];
    self.sessionUUID = [[NSUUID UUID] UUIDString];
    self.startSessionDate = [NSDate date];
    
    KZInitialSessionEvent *sessionStart = [[KZInitialSessionEvent alloc] initWithAttributes:self.deviceInfo.properties
                                                                                sessionUUID:self.sessionUUID];
    
    [self.allEvents addEvent:sessionStart];
    
}

- (void)loadEventsFromDisk {
    self.allEvents = [KZEvents eventsFromDisk];
}

- (NSArray *)events {
    return self.allEvents.events;
}

- (BOOL)hasEvents {
    return [self.allEvents.events count] > 0;
}

- (BOOL)shouldUploadSessionUsingBackgroundDate:(NSDate *)backgroundDate
{
    return self.startSessionDate != nil &&
            backgroundDate != nil &&
            [[NSDate date] timeIntervalSinceDate:backgroundDate] > self.sessionTimeout;
}

- (KZSessionEvent *)eventForCurrentSessionWithLength:(NSNumber *)length
{
    KZSessionEvent *sessionEvent = [[KZSessionEvent alloc] initWithAttributes:self.sessionAttributes
                                                                sessionLength:length
                                                                  sessionUUID:self.sessionUUID
                                                                  timeElapsed:@(0)];
    return sessionEvent;
}

- (void)logSessionWithLength:(NSNumber *)length
{
    [self logEvent:[self eventForCurrentSessionWithLength:length]];
}

- (void)setValue:(NSString *)value forSessionAttribute:(NSString *)key
{
    if (key != nil && value != nil) {
        self.sessionAttributes[key] = value;
    }
}

@end
