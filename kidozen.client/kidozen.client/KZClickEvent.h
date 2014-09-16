//
//  KZClickEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZPredefinedEvent.h"

@interface KZClickEvent : KZPredefinedEvent

-(instancetype) initWithEventValue:(NSString *)eventValue sessionUUID:(NSString *)sessionUUID;

@end
