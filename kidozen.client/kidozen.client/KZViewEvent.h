//
//  KZViewEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZPredefinedEvent.h"

/**
 This Event represents just a view event. Nothing more, nothing less.
 */
@interface KZViewEvent : KZPredefinedEvent

/**
 *  Initializer.
 *
 *  @param eventValue  is the button name, such as "LoginView"
 *  @param sessionUUID is the session ID to which the event belongs.
 *  @param userId      is the user's Kidozen's ID.
 *
 */
-(instancetype) initWithEventValue:(NSString *)eventValue
                       sessionUUID:(NSString *)sessionUUID
                            userId:(NSString *)userId
                       timeElapsed:(NSNumber *)timeElapsed;

@end
