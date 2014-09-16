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
{
    self = [super initWithEventName:eventName sessionUUID:sessionUUID];
    
    if (self) {
        self.attributes = attributes;
    }
}

- (NSDictionary *)serializedEvent
{
    NSDictionary *params;
    
    if (self.attributes != nil) {
        NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        mutableAttributes[@"sessionUUID"] = self.sessionUUID;
        
        params = @{@"eventName" : self.eventName,
                   @"eventAttr" : mutableAttributes};
    } else {
        params = @{@"eventName" : self.eventName,
                   @"sessionUUID" : self.sessionUUID };
    }

    return params;
}

@end
