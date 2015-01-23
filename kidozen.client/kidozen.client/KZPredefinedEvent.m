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

@property (nonatomic, readwrite, copy) NSString *eventName;
@property (nonatomic, readwrite, copy) NSString *sessionUUID;
@property (nonatomic, strong) NSNumber *timeElapsed;

@end

@interface KZPredefinedEvent()

@property (nonatomic, readwrite, copy) NSString *eventValue;

@end

@implementation KZPredefinedEvent

-(instancetype) initWithEventName:(NSString *)eventName
                            value:(NSString *)eventValue
                      sessionUUID:(NSString *)sessionUUID
                      timeElapsed:(NSNumber *)timeElapsed
{
    self = [super initWithEventName:eventName sessionUUID:sessionUUID timeElapsed:timeElapsed];
    
    if (self) {
        self.eventValue = eventValue;
    }
    return self;

}

- (NSDictionary *)serializedEvent {
    
    return  @{@"eventName" : self.eventName,
              @"eventValue" : self.eventValue,
              @"sessionUUID" : self.sessionUUID,
              @"elapsedTime" : self.timeElapsed };
}

@end