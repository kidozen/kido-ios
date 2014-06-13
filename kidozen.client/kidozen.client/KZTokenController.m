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

@property (nonatomic, copy) void(^timerCallback)(void);

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

- (void)startTokenExpirationTimer:(NSInteger)timeout callback:(void(^)(void))callback
{
    self.timerCallback = callback;
    
    __block NSTimer *tokenTimer;
    __weak KZTokenController *safeMe = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        tokenTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                     target:safeMe
                                                   selector:@selector(tokenExpires)
                                                   userInfo:callback
                                                    repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:tokenTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void) tokenExpires
{
    if (self.timerCallback != nil) {
        self.timerCallback();
    }
}

@end
