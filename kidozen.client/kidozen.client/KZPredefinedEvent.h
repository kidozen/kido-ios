//
//  KZPredefinedEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZEvent.h"

/**
 *  Subclasses of this class will be events by default that the SDK will handle.
 */
@interface KZPredefinedEvent : KZEvent

- (instancetype)initWithEventName:(NSString *)eventName
                            value:(NSString *)eventValue
                      sessionUUID:(NSString *)sessionUUID
                      timeElapsed:(NSNumber *)timeElapsed;

// Will contain the value of the event, such as "OkButton" or "InitialView" or something like that.
@property (nonatomic, readonly, copy) NSString *eventValue;

@end
