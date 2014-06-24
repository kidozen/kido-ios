//
//  KZTokenController.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KZTokenController : NSObject

@property (nonatomic, copy, readonly) NSString *rawAccessToken;
@property (nonatomic, copy, readonly) NSString *kzToken;
@property (nonatomic, copy, readonly) NSString *ipToken;

@property (nonatomic, copy, readonly) NSString *refreshToken;


- (void)updateAccessTokenWith:(NSString *)accessToken accessTokenKey:(NSString *)accessTokenKey;
- (void)updateIPTokenWith:(NSString *)ipToken ipKey:(NSString *)ipKey;

- (void)clearAccessTokenForKey:(NSString *)key;
- (void)clearIPTokenForKey:(NSString *)key;

- (void)loadTokensFromCacheForIpKey:(NSString *)ipKey accessTokenKey:(NSString *)accessTokenKey;
- (void)removeTokensFromCache;

- (void)updateRefreshTokenWith:(NSString *)refreshToken;

- (void)startTokenExpirationTimer:(NSInteger)timeout callback:(void(^)(void))callback;

@end
