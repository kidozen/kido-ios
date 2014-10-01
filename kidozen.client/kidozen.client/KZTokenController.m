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
@property (nonatomic, copy, readwrite) NSString *refreshToken;

@property (nonatomic, strong) NSTimer *tokenTimer;

// We store the dictionary that comes as authentication response.
// It's required for data visualization.
@property (nonatomic, strong) NSDictionary *authenticationResponse;

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

- (void)updateRefreshTokenWith:(NSString *)refreshToken
{
    self.refreshToken = refreshToken;
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


- (void)storeAuthenticationResponse:(NSDictionary *)authenticationResponse
{
    self.authenticationResponse = authenticationResponse;
}

- (NSString *)jsonifiedAuthenticationResponse
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.authenticationResponse
                                                       options:0
                                                         error:&error];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)startTokenExpirationTimer:(NSInteger)timeout callback:(void(^)(void))callback
{
#ifdef CURRENTLY_TESTING
    NSLog(@"-- Currently testing, setting timeout to 30 sec.");
    timeout = 30;
#endif

    if (timeout > 0) {
        self.timerCallback = callback;
        if (self.tokenTimer != nil) {
            [self.tokenTimer invalidate];
            self.tokenTimer = nil;
        }
        
        __block NSTimer *safeTokenTimer = self.tokenTimer;
        __weak KZTokenController *safeMe = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            safeTokenTimer = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                          target:safeMe
                                                        selector:@selector(tokenExpires)
                                                        userInfo:callback
                                                         repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:safeTokenTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    } else {
        NSLog(@"Warning, key expiration is zero");
    }
}

- (void) tokenExpires
{
    [self.tokenTimer invalidate];
    self.tokenTimer = nil;
    
    if (self.timerCallback != nil) {
        self.timerCallback();
    }
}

@end
