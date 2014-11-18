//
//  KZCustomEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZEvent.h"

/**
 *  Represents a custom event which should be created by the developer.
 */
@interface KZCustomEvent : KZEvent


/**
 *  Initializer.
 *
 *  @param eventName   Is the name of the Event, such as "TaskCreated"
 *  @param attributes  Is a dictionary that corresponds to the event. Something like @{"Category" : "Critical"}
 *  @param sessionUUID Is the session's ID to which the event belongs.
 *
 *  @return an instance of KZCustomEvent.
 */
-(instancetype) initWithEventName:(NSString *)eventName
                       attributes:(NSDictionary *)attributes
                      sessionUUID:(NSString *)sessionUUID;

@end
