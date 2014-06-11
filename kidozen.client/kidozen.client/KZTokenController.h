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


- (void) updateAccessTokenWith:(NSString *)accessToken accessTokenKey:(NSString *)accessTokenKey;
- (void) updateIPTokenWith:(NSString *)ipToken ipKey:(NSString *)ipKey;

//- (void) clearAccessToken;
//- (void) clearIPToken;

-(void) loadTokensFromCacheForIpKey:(NSString *)ipKey accessTokenKey:(NSString *)accessTokenKey;
-(void) removeTokensFromCache;

@end
