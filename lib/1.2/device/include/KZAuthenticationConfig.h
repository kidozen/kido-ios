//
//  KZAuthenticationConfig.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZObject.h"

/* 
 * This class is just a model for the authentication config response.
 */
@interface KZAuthenticationConfig : KZObject

@property (nonatomic, copy, readonly) NSString *applicationScope;
@property (nonatomic, copy, readonly) NSString *authServiceScope;
@property (nonatomic, copy, readonly) NSString *authServiceEndpoint;
@property (nonatomic, copy, readonly) NSString *oauthTokenEndpoint;
@property (nonatomic, copy, readonly) NSString *signInUrl;

@property (nonatomic, readonly) NSDictionary *identityProviders;

- (id)initWithDictionary:(NSDictionary *)configDictionary;

- (NSString *)protocolForProvider:(NSString *)provider;
- (NSString *)endPointForProvider:(NSString *)provider;

@end
