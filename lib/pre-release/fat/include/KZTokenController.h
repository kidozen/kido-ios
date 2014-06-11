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

- (void) updateAccessTokenWith:(NSString *)accessToken;
- (void) updateIPTokenWith:(NSString *)ipToken;

- (void) clearAccessToken;
- (void) clearIPToken;

@end
