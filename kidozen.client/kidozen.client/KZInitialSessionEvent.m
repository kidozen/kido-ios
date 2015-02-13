//
//  KZInitialSessionEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 2/12/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZInitialSessionEvent.h"

@implementation KZInitialSessionEvent

-(instancetype) initWithAttributes:(NSDictionary *)attributes
                       sessionUUID:(NSString *)sessionUUID
{
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary:attributes];
        attr[@"platform"] = @"iOS";
        
        return [super initWithEventName:@"sessionStart"
                             attributes:attr
                            sessionUUID:sessionUUID
                            timeElapsed:@(0)];
}

@end
