//
//  KZDatasource.m
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDatasource.h"

#define EINVALIDCALL 1
#define DATASOURCE_ERROR_DOMAIN @"DataSource"

@implementation KZDatasource

-(void) Query:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:[NSString stringWithFormat:@"%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        block( [[KZResponse alloc] initWithResponse:response
                                        urlResponse:urlResponse
                                           andError:error] );
    }];
}

-(void) Invoke:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client setSendParametersAsJSON:YES];
    [_client POST:self.name parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[[NSString alloc] initWithData:response encoding:NSASCIIStringEncoding] forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:DATASOURCE_ERROR_DOMAIN code:EINVALIDCALL userInfo:details];
        }
        block( [[KZResponse alloc] initWithResponse:response
                                        urlResponse:urlResponse
                                           andError:error] );
    }];
}

@end
