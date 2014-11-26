//
//  KZSessionEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZSessionEvent.h"

@implementation KZSessionEvent

-(instancetype) initWithAttributes:(NSDictionary *)attributes
                     sessionLength:(NSNumber *)length
                       sessionUUID:(NSString *)sessionUUID
                       timeElapsed:(NSNumber *)timeElapsed
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attributes];
    attr[@"sessionLength"] = length;
    attr[@"platform"] = @"iOS";
    
    return [super initWithEventName:@"user-session"
                         attributes:attr
                        sessionUUID:sessionUUID
                        timeElapsed:timeElapsed];
}

@end
