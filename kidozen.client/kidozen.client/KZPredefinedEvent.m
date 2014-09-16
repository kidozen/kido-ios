//
//  KZPredefinedEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZPredefinedEvent.h"

// we import private/protected properties.
@interface KZEvent()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *sessionUUID;

@end

@interface KZPredefinedEvent()

@property (nonatomic, copy) NSString *eventValue;

@end

@implementation KZPredefinedEvent

-(instancetype) initWithEventName:(NSString *)eventName value:(NSString *)eventValue sessionUUID:(NSString *)sessionUUID
{
    self = [super initWithEventName:eventName sessionUUID:sessionUUID];
    if (self) {
        self.eventValue = eventValue;
    }
    return self;

}

@end
