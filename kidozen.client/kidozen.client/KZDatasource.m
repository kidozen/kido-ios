//
//  KZDatasource.m
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDatasource.h"

#define EINVALIDCALL 1
#define EINVALIDPARAM 2
#define DATASOURCE_ERROR_DOMAIN @"DataSource"


@implementation KZDatasource

-(void)addHeadersWithTimeout:(int)timeout
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    if (timeout > 0) {
        headers[@"timeout"] = [NSString stringWithFormat:@"%d", timeout];
    }
    
    [_client setHeaders:headers];

    [self addAuthorizationHeader];

}

-(void) queryWithData: (id) data completion:(void (^)(KZResponse *))block
{
    [self QueryWithData:data timeout:0 completion:block];
}

-(void) QueryWithData:(NSDictionary *)data timeout:(int)timeout completion:(void (^)(KZResponse *))block
{
    [self addHeadersWithTimeout:timeout];
    
    _client.sendParametersAsJSON = NO;
    
    [_client GET:self.name parameters:data completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
        }
    }];
    
}

-(void) invokeWithData: (NSDictionary *) data completion:(void (^)(KZResponse *))block
{
    [self InvokeWithData:data timeout:0 completion:block];
}
-(void) InvokeWithData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block
{
    [self addHeadersWithTimeout:timeout];
    
    [_client setSendParametersAsJSON:YES];
    [_client POST:self.name parameters:data completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
        }
    }];

}
- (void)InvokeWithTimeout:(int)timeout callback:(void (^)(KZResponse *))block
{
    [self InvokeWithData:@{} timeout:timeout completion:block];
}

-(NSDictionary *) dataAsDictionary : (id)data
{
    NSError* error;
    NSDictionary* json = Nil;
    if ([[data class] isSubclassOfClass:[NSData class]]) {
        json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
        json = data;
    }
    if (error) {
        return Nil;
    }
    else return json;
}

-(void) Query:(void (^)(KZResponse *))block
{
    [self QueryWithData:@{} completion:block];
}
-(void) QueryWithTimeout:(int)timeout callback:(void (^)(KZResponse *))block
{
    [self QueryWithData:@{} timeout:timeout completion:block];
}

-(void) Invoke:(void (^)(KZResponse *))block
{
    [self invokeWithData:@{} completion:block];
}

-(void) InvokeWithData:(id)data completion:(void (^)(KZResponse *))block
{
    NSDictionary * d = [self dataAsDictionary:data];
    if (!d) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid parameter. Must be a serializable json or nsdictionary" forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDPARAM userInfo:details];
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:Nil
                                            urlResponse:nil
                                               andError:error] );
        }

    }
    else
        [self invokeWithData:d completion:block];
}

-(void) QueryWithData:(id)data completion:(void (^)(KZResponse *))block
{
    NSDictionary * d = [self dataAsDictionary:data];
    if (!d) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid parameter. Must be a serializable json or nsdictionary" forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDPARAM userInfo:details];
        if (block != nil) {            
            block( [[KZResponse alloc] initWithResponse:Nil
                                            urlResponse:nil
                                               andError:error] );
            
        }
    }
    else
        [self queryWithData:d completion:block];
}

@end
