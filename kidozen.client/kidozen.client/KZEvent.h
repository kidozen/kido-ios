//
//  KZEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <kidozen.client/kidozen.client.h>


@interface KZEvent : KZObject

-(instancetype) initWithEventName:(NSString *)eventName sessionUUID:(NSString *)sessionUUID;

- (NSDictionary *)serializedEvent;

@end
