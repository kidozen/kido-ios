//
//  KZCustomAPI.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 3/26/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZBaseService.h"

@interface KZCustomAPI : KZBaseService

- (void) executeCustomAPI:(NSDictionary *)scriptDictionary completion:(void (^)(KZResponse *))block;

@end
