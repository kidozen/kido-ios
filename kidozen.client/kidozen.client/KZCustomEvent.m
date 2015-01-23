//
//  KZCustomEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZCustomEvent.h"

@interface KZCustomEvent()

@property (nonatomic, strong) NSDictionary *attributes;

@end


@implementation KZCustomEvent

-(instancetype) initWithEventName:(NSString *)eventName
                       attributes:(NSDictionary *)attributes
                      sessionUUID:(NSString *)sessionUUID
                      timeElapsed:(NSNumber *)timeElapsed
{
    self = [super initWithEventName:eventName sessionUUID:sessionUUID timeElapsed:timeElapsed];
    
    if (self) {
        self.attributes = attributes;
    }
    return self;
}

- (NSDictionary *)serializedEvent
{
    NSDictionary *params;
    
    if (self.attributes != nil) {
        params = @{@"eventName" : self.eventName,
                   @"sessionUUID" : self.sessionUUID,
                   @"eventAttr" : self.attributes,
                   @"elapsedTime" : self.timeElapsed };
    } else {
        params = @{@"eventName" : self.eventName,
                   @"sessionUUID" : self.sessionUUID,
                   @"elapsedTime" : self.timeElapsed };
    }

    return params;
}

@end