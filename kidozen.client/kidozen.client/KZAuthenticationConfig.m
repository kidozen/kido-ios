//
//  KZAuthenticationConfig.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/30/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZAuthenticationConfig.h"

NSString *const kEndPointKey = @"endpoint";

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


- (NSString *)passiveEndPointStringForProvider:(NSString *)provider
{
    NSDictionary *providerInfo = [self.passiveIdentityProviders objectForKey:provider];
    return providerInfo[kEndPointKey];
}


- (NSString *)protocolForProvider:(NSString *)provider {
    NSString *const kProtocolKey = @"protocol";

    NSDictionary *providerInfo = [self.identityProviders objectForKey:provider];
    return providerInfo[kProtocolKey];
}

- (NSString *)endPointForProvider:(NSString *)provider {
    NSDictionary *providerInfo = [self.identityProviders objectForKey:provider];
    return providerInfo[kEndPointKey];
}

@end
