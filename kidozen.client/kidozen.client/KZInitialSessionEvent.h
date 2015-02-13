//
//  KZInitialSessionEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 2/12/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZCustomEvent.h"

/**
 * Represents a session event, which contains information related
 * to the current session.
 */
@interface KZInitialSessionEvent : KZCustomEvent

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
                       sessionUUID:(NSString *)sessionUUID;

@end
