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
                       sessionUUID:(NSString *)sessionUUID
{
    return [super initWithEventName:@"user-session" attributes:attributes sessionUUID:sessionUUID];
}

@end
