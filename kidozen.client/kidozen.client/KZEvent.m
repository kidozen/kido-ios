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
@property (nonatomic, strong) NSNumber *timeElapsed;

@end


@implementation KZEvent

-(instancetype) initWithEventName:(NSString *)eventName
                      sessionUUID:(NSString *)sessionUUID
                      timeElapsed:(NSNumber *)timeElapsed
{
    self = [super init];
    if (self) {
        NSCharacterSet *chSet = [NSCharacterSet characterSetWithCharactersInString:@" -,.;:"];
        self.eventName = [[eventName componentsSeparatedByCharactersInSet: chSet] componentsJoinedByString: @""];
        self.sessionUUID = sessionUUID;
        self.timeElapsed = timeElapsed;
    }
    return self;
}

- (NSDictionary *)serializedEvent
{
    NSAssert(NO, @"Subclasses must override this method");
    return nil;
}

@end
