//
//  KZAuthenticationConfig.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZAuthenticationConfig.h"

@interface KZAuthenticationConfig()

@property (nonatomic, copy, readwrite) NSString *applicationScope;
@property (nonatomic, copy, readwrite) NSString *authServiceScope;
@property (nonatomic, copy, readwrite) NSString *authServiceEndpoint;
@property (nonatomic, copy, readwrite) NSString *oauthTokenEndpoint;
@property (nonatomic, strong) NSDictionary *identityProviders;
@property (nonatomic, strong) NSDictionary *passiveIdentityProviders;

@end

@implementation KZAuthenticationConfig

- (instancetype)initWithDictionary:(NSDictionary *)configDictionary
{
    self = [super init];
    if (self) {
        [self configureWithDictionary:configDictionary];
    }
    return self;
}

@end
