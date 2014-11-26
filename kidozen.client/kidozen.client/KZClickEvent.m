//
//  KZClickEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZClickEvent.h"

@implementation KZClickEvent

-(instancetype) initWithEventValue:(NSString *)eventValue sessionUUID:(NSString *)sessionUUID timeElapsed:(NSNumber *)timeElapsed
{
    return [super initWithEventName:@"Click" value:eventValue sessionUUID:sessionUUID timeElapsed:timeElapsed];
}


@end
