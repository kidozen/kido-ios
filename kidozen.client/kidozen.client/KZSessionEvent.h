//
//  KZSessionEvent.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZCustomEvent.h"

@interface KZSessionEvent : KZCustomEvent

-(instancetype) initWithAttributes:(NSDictionary *)attributes
                       sessionUUID:(NSString *)sessionUUID;

@end
