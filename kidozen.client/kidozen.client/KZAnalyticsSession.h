//
//  KZAnalyticsSession.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/18/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZEvent;
@class KZDeviceInfo;
@class KZSessionEvent;

@interface KZAnalyticsSession : NSObject

@property (nonatomic, readonly, copy) NSString *sessionUUID;
@property (nonatomic, assign) NSUInteger sessionTimeout;
@property (nonatomic, readonly) NSArray *events;
@property (nonatomic, readonly, strong) NSDate *startSessionDate;


- (BOOL)shouldUploadSessionUsingBackgroundDate:(NSDate *)backgroundDate;
- (void)logSessionWithLength:(NSNumber *)length;
- (void)logEvent:(KZEvent *)event;

- (void)removeSavedEvents;
- (void)startNewSession;
- (void)save;
- (void)loadEventsFromDisk;
- (void)removeCurrentEvents;

- (BOOL)hasEvents;

@end
