//
//  KZTokenController.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * The main idea of this class is to centralize all operations related to 
 * tokens.
 */
@interface KZTokenController : NSObject

@property (nonatomic, copy, readonly) NSString *rawAccessToken;
@property (nonatomic, copy, readonly) NSString *kzToken;
@property (nonatomic, copy, readonly) NSString *ipToken;

// We store the dictionary that comes as authentication response.
// It's required for data visualization.
@property (nonatomic, strong) NSDictionary *authenticationResponse;

@property (nonatomic, copy, readonly) NSString *refreshToken;


- (void)updateAccessTokenWith:(NSString *)accessToken accessTokenKey:(NSString *)accessTokenKey;
- (void)updateIPTokenWith:(NSString *)ipToken ipKey:(NSString *)ipKey;

- (void)clearAccessTokenForKey:(NSString *)key;
- (void)clearIPTokenForKey:(NSString *)key;

- (void)loadTokensFromCacheForIpKey:(NSString *)ipKey accessTokenKey:(NSString *)accessTokenKey;
- (void)removeTokensFromCache;

- (void)updateRefreshTokenWith:(NSString *)refreshToken;

// Tokens have an expiration time, this will trigger the timer which, when reaches 0,
// the callback method will get called.
- (void)startTokenExpirationTimer:(NSInteger)timeout callback:(void(^)(void))callback;

@end
