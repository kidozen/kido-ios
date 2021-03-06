//
//  KZCustomEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZCustomEvent.h"
#import "KZDeviceInfo.h"

@interface KZCustomEvent()

@property (nonatomic, strong) NSDictionary *attributes;

@end


@implementation KZCustomEvent

-(instancetype) initWithEventName:(NSString *)eventName
                       attributes:(NSDictionary *)attributes
                      sessionUUID:(NSString *)sessionUUID
                           userId:(NSString *)userId
                      timeElapsed:(NSNumber *)timeElapsed
{
    self = [super initWithEventName:eventName
                        sessionUUID:sessionUUID
                             userId:userId
                        timeElapsed:timeElapsed];
    
    if (self) {
        self.attributes = attributes;
    }
    return self;
}

- (NSDictionary *)serializedEvent
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    
    if (self.attributes != nil) {
        [attr addEntriesFromDictionary:self.attributes];
    }
    
    attr[@"platform"] = @"iOS";
    attr[@"appVersion"] = [KZDeviceInfo sharedDeviceInfo].appVersion;
    
    NSDictionary *params = @{@"eventName" : self.eventName,
                            @"sessionUUID" : self.sessionUUID,
                             @"userid" : self.userId,
                            @"eventAttr" : attr,
                            @"elapsedTime" : self.timeElapsed
                            };
    
    return params;
}

@end
