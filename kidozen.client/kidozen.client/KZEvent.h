//
//  KZEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

/**
 *  The Event base class. Contains the barely minimum properties that an event needs.
 */
@interface KZEvent : NSObject

/**
 *  Initializer.
 *
 *  @param eventName   Is the name of this event. An example can be something like "Click, View, etc..."
 *  @param sessionUUID The session ID to which this event belongs.
 *
 */
-(instancetype) initWithEventName:(NSString *)eventName
                      sessionUUID:(NSString *)sessionUUID
                           userId:(NSString *)userId
                      timeElapsed:(NSNumber *)timeElapsed;

@property (nonatomic, readonly, copy) NSString *eventName;
@property (nonatomic, readonly, copy) NSString *sessionUUID;
@property (nonatomic, readonly) NSNumber *timeElapsed;
@property (nonatomic, readonly, copy) NSString *userId;

/**
 *  @return a dictionary representation of this event
 */
- (NSDictionary *)serializedEvent;

@end
