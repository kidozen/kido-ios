//
//  KZAuthenticationConfig.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZObject.h"

@interface KZAuthenticationConfig : KZObject

- (id)initWithDictionary:(NSDictionary *)configDictionary;

@property (nonatomic, copy, readonly) NSString *applicationScope;
@property (nonatomic, copy, readonly) NSString *authServiceScope;
@property (nonatomic, copy, readonly) NSString *authServiceEndpoint;
@property (nonatomic, copy, readonly) NSString *oauthTokenEndpoint;
@property (nonatomic, readonly) NSDictionary *identityProviders;

@end
