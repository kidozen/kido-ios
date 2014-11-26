//
//  KZSessionEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZCustomEvent.h"

/**
 * Represents a session event, which contains information related
 * to the current session.
 */
@interface KZSessionEvent : KZCustomEvent

/**
 *  Initializer.
 *
 *  @param attributes  dictionary that contains information related to the current session along with
 *                     information related to the device.
 *  @param length      amount of seconds that the current se
 *  @param sessionUUID the session identifier
 *
 */
-(instancetype) initWithAttributes:(NSDictionary *)attributes
                     sessionLength:(NSNumber *)length
                       sessionUUID:(NSString *)sessionUUID
                       timeElapsed:(NSNumber *)timeElapsed;

@end
