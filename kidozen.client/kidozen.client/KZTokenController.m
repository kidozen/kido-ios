//
//  KZTokenController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZTokenController.h"

@interface KZTokenController()

@property (nonatomic, strong) NSMutableDictionary *tokenCache;
@property (nonatomic, copy, readwrite) NSString *rawAccessToken;
@property (nonatomic, copy, readwrite) NSString *kzToken;
@property (nonatomic, copy, readwrite) NSString *ipToken;

@end

@implementation KZTokenController

- (void) updateAccessTokenWith:(NSString *)accessToken accessTokenKey:(NSString *)accessTokenKey
{
    if (accessToken != nil && accessToken.length > 0) {
        self.rawAccessToken = accessToken;
        self.kzToken = [self kzTokenFromRawAccessToken];
        self.tokenCache[accessTokenKey] = accessToken;
    }
}

- (void) updateIPTokenWith:(NSString *)ipToken ipKey:(NSString *)ipKey
{
    if (ipToken != nil && ipToken.length > 0) {
        self.ipToken = ipToken;
        self.tokenCache[ipKey] = ipToken;
    }
}

- (NSString *)kzTokenFromRawAccessToken
{
    return [NSString stringWithFormat:@"WRAP access_token=\"%@\"", self.rawAccessToken];
}

- (void) clearAccessTokenForKey:(NSString *)key
{
    self.rawAccessToken = nil;
    self.kzToken = nil;
    [self.tokenCache removeObjectForKey:key];
}

- (void) clearIPTokenForKey:(NSString *)key
{
    self.ipToken = nil;
    [self.tokenCache removeObjectForKey:key];
}

-(void) loadTokensFromCacheForIpKey:(NSString *)ipKey accessTokenKey:(NSString *)accessTokenKey
{
    [self setRawAccessToken:self.tokenCache[accessTokenKey]];
    self.ipToken = self.tokenCache[ipKey];
}

-(void) removeTokensFromCache
{
    [self.tokenCache removeAllObjects];
}

@end
