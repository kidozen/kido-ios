//
//  KZDatasource.m
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDatasource.h"

@implementation KZDatasource

-(void) Query:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:[NSString stringWithFormat:@"%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
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
        block( [[KZResponse alloc] initWithResponse:response
                                        urlResponse:urlResponse
                                           andError:error] );
    }];
}

@end
