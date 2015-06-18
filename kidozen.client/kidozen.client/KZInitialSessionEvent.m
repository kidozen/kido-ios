//
//  KZInitialSessionEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 2/12/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZInitialSessionEvent.h"
#import "KZDeviceInfo.h"

@implementation KZInitialSessionEvent

-(instancetype) initWithAttributes:(NSDictionary *)attributes
                       sessionUUID:(NSString *)sessionUUID
                            userId:(NSString *)userId
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attributes];
    attr[@"platform"] = @"iOS";
    attr[@"appVersion"] = [KZDeviceInfo sharedDeviceInfo].appVersion;
    
    return [super initWithEventName:@"sessionStart"
                         attributes:attr
                        sessionUUID:sessionUUID
                             userId:userId
                        timeElapsed:@(0)];
}

@end
