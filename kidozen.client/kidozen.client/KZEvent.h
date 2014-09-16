//
//  KZEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

@interface KZEvent : NSObject

@property (nonatomic, readonly, copy) NSString *eventName;
@property (nonatomic, readonly, copy) NSString *sessionUUID;

-(instancetype) initWithEventName:(NSString *)eventName sessionUUID:(NSString *)sessionUUID;

- (NSDictionary *)serializedEvent;

@end
