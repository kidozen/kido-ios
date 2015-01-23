//
//  KZClickEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZPredefinedEvent.h"

/**
 This Event represents just a click/tap event. Nothing more, nothing less.
 */
@interface KZClickEvent : KZPredefinedEvent

/**
 *  Initializer.
 *
 *  @param eventValue  is the button name, such as "CreateButton"
 *  @param sessionUUID is the session ID to which the event belongs.
 *
 *  @return an instance of KZClickEvent.
 */
-(instancetype) initWithEventValue:(NSString *)eventValue
                       sessionUUID:(NSString *)sessionUUID
                       timeElapsed:(NSNumber *)timeElapsed;

@end
