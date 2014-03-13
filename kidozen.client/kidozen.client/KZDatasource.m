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

-(void) queryWithData: (NSDictionary *) data completion:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:self.name parameters:data completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
}
-(void) invokeWithData: (NSDictionary *) data completion:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client setSendParametersAsJSON:YES];
    [_client POST:self.name parameters:data completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
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
    [self queryWithData:Nil completion:block];
}

-(void) Invoke:(void (^)(KZResponse *))block
{
    [self invokeWithData:Nil completion:block];
}

-(void) InvokeWithData:(id)data completion:(void (^)(KZResponse *))block
{
    NSDictionary * d = [self dataAsDictionary:data];
    if (!d) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Invalid parameter. Must be a serializable json or nsdictionary" forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDPARAM userInfo:details];
        block( [[KZResponse alloc] initWithResponse:Nil
                                        urlResponse:nil
                                           andError:error] );

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
        block( [[KZResponse alloc] initWithResponse:Nil
                                        urlResponse:nil
                                           andError:error] );
        
    }
    else
        [self queryWithData:d completion:block];
}

@end
