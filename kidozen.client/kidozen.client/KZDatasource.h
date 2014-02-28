//
//  KZDatasource.h
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZService.h"

@interface KZDatasource : KZService

-(void) Query:(void (^)(KZResponse *))block;

-(void) Invoke:(void (^)(KZResponse *))block;

@end
