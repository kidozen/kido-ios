//
//  KZTokenController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZTokenController.h"

@interface KZTokenController()

@property (nonatomic, copy, readwrite) NSString *rawAccessToken;
@property (nonatomic, copy, readwrite) NSString *kzToken;
@property (nonatomic, copy, readwrite) NSString *ipToken;

@end

@implementation KZTokenController

- (void) updateAccessTokenWith:(NSString *)accessToken
{
    if (accessToken != nil && accessToken.length > 0) {
        self.rawAccessToken = accessToken;
        self.kzToken = [self kzTokenFromRawAccessToken];
    }
}

- (void) updateIPTokenWith:(NSString *)ipToken
{
    if (ipToken != nil && ipToken.length > 0) {
        self.ipToken = ipToken;
    }
}

- (NSString *)kzTokenFromRawAccessToken
{
    return [NSString stringWithFormat:@"WRAP access_token=\"%@\"", self.rawAccessToken];
}

- (void) clearAccessToken
{
    self.rawAccessToken = nil;
    self.kzToken = nil;
}

- (void) clearIPToken
{
    self.ipToken = nil;
}


@end
