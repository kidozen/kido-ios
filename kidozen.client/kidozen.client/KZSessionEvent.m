//
//  KZSessionEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZSessionEvent.h"
#import "KZDeviceInfo.h"

@implementation KZSessionEvent

-(instancetype) initWithAttributes:(NSDictionary *)attributes
                     sessionLength:(NSNumber *)length
                       sessionUUID:(NSString *)sessionUUID
                            userId:(NSString *)userId
                       timeElapsed:(NSNumber *)timeElapsed
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attributes];
    attr[@"sessionLength"] = length;
    attr[@"platform"] = @"iOS";
    attr[@"appVersion"] = [KZDeviceInfo sharedDeviceInfo].appVersion;
    
    return [super initWithEventName:@"sessionEnd"
                         attributes:attr
                        sessionUUID:sessionUUID
                             userId:userId
                        timeElapsed:timeElapsed];
}

@end
