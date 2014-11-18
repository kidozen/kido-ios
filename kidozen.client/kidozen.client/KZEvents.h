//
//  KZEvents.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZEvent;

/**
 *  Is a handy class that contains all events.
 */
@interface KZEvents : NSObject

/**
 *  Creates an instance of KZEvents with events that are persisted on disk.
 *  If there are no events in disk, then we just create an empty instance.
 *
 */
+(instancetype)eventsFromDisk;

@property (nonatomic, readonly) NSMutableArray *events;

/**
 *  Will remove any persisted events
 */
- (void)removeSavedEvents;

/**
 *  Adds and event to the session.
 *
 *  @param event is the event that will be added.
 */
- (void)addEvent:(KZEvent *)event;

/**
 *  Saves current session with all current events.
 */
- (void)save;

/**
 *  Will remove current in-memory events.
 */
- (void)removeCurrentEvents;

@end
