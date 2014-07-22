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
-(void) QueryWithTimeout:(int)timeout callback:(void (^)(KZResponse *))block;

-(void) Invoke:(void (^)(KZResponse *))block;
-(void) InvokeWithTimeout:(int)timeout callback:(void (^)(KZResponse *))block;

-(void) QueryWithData:(id)data completion:(void (^)(KZResponse *))block;
-(void) QueryWithData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block;

-(void) InvokeWithData:(id)data completion:(void (^)(KZResponse *))block;
-(void) InvokeWithData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block;

@end
