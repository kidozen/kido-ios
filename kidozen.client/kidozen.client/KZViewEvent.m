//
//  KZViewEvent.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZViewEvent.h"

@implementation KZViewEvent

-(instancetype) initWithEventValue:(NSString *)eventValue
                       sessionUUID:(NSString *)sessionUUID
                            userId:(NSString *)userId
                       timeElapsed:(NSNumber *)timeElapsed
{
    return [super initWithEventName:@"View"
                              value:eventValue
                        sessionUUID:sessionUUID
                             userId:userId
                        timeElapsed:timeElapsed];
}

@end
