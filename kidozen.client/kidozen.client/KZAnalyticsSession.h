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

/**
 *  This class models an entire session of events. It contains all tagged events
 *  and provides some methods and properties to determine when a session should end.
 */
@interface KZAnalyticsSession : NSObject

/**
 * This property is the session's id. It will be the same through all events
 * contained in this class
 */
@property (nonatomic, readonly, copy) NSString *sessionUUID;

/**
 * This property represents the amount of seconds your application should
 * remain in a background state until it's considered finished.
 */
@property (nonatomic, assign) NSUInteger sessionTimeout;

/**
 *  It's the array of events contained in this session
 */
@property (nonatomic, readonly) NSArray *events;

/**
 *  The date (which can also bring the timestamp)
 */
@property (nonatomic, readonly, strong) NSDate *startSessionDate;

/**
 *  Will return whether the session events should be uploaded to the cloud, which 
 *  depends on the sessionTimeOut.
 *
 *  @param backgroundDate is the date when the application was set to background.
 *
 *  @return YES if the difference is > than sessionTimeOut. NO otherwise.
 */
- (BOOL)shouldUploadSessionUsingBackgroundDate:(NSDate *)backgroundDate;

/**
 *  Adds and event to the session.
 *
 *  @param event is the event that will be added.
 */
- (void)logEvent:(KZEvent *)event;

/**
 *  Will remove any persisted events
 */
- (void)removeSavedEvents;

/**
 *  Removes all previous events and starts a brand new session
 */
- (void)startNewSession;

/**
 *  Saves current session with all current events.
 */
- (void)save;

/**
 *  Will load previous events from disk
 */
- (void)loadEventsFromDisk;

/**
 *  Will remove current in-memory events.
 */
- (void)removeCurrentEvents;

/**
 *  Returns whether the current session contains events
 *
 *  @return YES if we've got events in this session. NO otherwise.
 */
- (BOOL)hasEvents;

@end
