//
//  KZCustomAPI.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 3/26/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZCustomAPI.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZCustomAPI


- (void) executeCustomAPI:(NSDictionary *)scriptDictionary completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    [self.client setSendParametersAsJSON:YES];
    NSString *name = [self.name copy];
    
    if (![self.name hasSuffix:@"/"]) {
        name = [NSString stringWithFormat:@"/%@", self.name];
    }
    
    [self.client POST:name
           parameters:scriptDictionary
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block
                         response:response
                      urlResponse:urlResponse
                            error:error];
               
           }];

}

@end
