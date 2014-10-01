//
//  KZEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZEvent.h"

@interface KZEvent()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *sessionUUID;

@end


@implementation KZEvent

-(instancetype) initWithEventName:(NSString *)eventName sessionUUID:(NSString *)sessionUUID
{
    self = [super init];
    if (self) {
        self.eventName = eventName;
        self.sessionUUID = sessionUUID;
    }
    return self;
}

- (NSDictionary *)serializedEvent
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

@end
