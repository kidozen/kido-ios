//
//  KZPredefinedEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZEvent.h"

@interface KZPredefinedEvent : KZEvent

@property (nonatomic, readonly, copy) NSString *eventValue;

- (instancetype)initWithEventName:(NSString *)eventName value:(NSString *)eventValue sessionUUID:(NSString *)sessionUUID;

@end
