//
//  KZApplicationAuthentication.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/14/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZApplicationAuthentication.h"
#import "KZTokenController.h"
#import "KZApplicationConfiguration.h"
#import "KZAuthenticationConfig.h"
#import "KZIdentityProviderFactory.h"
#import "KZIdentityProvider.h"
#import "SVHTTPClient.h"
#import "KZUser.h"
#import "KZPassiveAuthViewController.h"
#import "NSData+Conversion.h"

NSString *const kAccessTokenKey = @"access_token";

@interface KZApplicationAuthentication()

@property (nonatomic, copy) NSString *applicationKey;

@property (nonatomic, copy) NSString *tenantMarketPlace;

@property (nonatomic, copy) NSString *lastUserName;
@property (nonatomic, copy) NSString *lastPassword;
@property (nonatomic, copy) NSString *lastProviderKey;

@property (nonatomic, strong) SVHTTPClient *defaultClient;

@property (nonatomic, strong) NSObject<KZIdentityProvider> *ip;

@property (nonatomic, assign) BOOL isAuthenticated;
@property (nonatomic, strong) KZUser * kzUser;

@property (nonatomic, assign) BOOL passiveAuthenticated;

@property (nonatomic, strong) KZTokenController *tokenController;
@property (nonatomic, strong) KZApplicationConfiguration *applicationConfig;

@property (nonatomic, assign) BOOL strictSSL;

@end

@implementation KZApplicationAuthentication

-(instancetype) initWithApplicationConfig:(KZApplicationConfiguration *)applicationConfig
                      tenantMarketPlace:(NSString *)tenantMarketPlace
                              strictSSL:(BOOL)strictSSL
{
    self = [super init];
    if (self) {
        self.passiveAuthenticated = NO;
        self.strictSSL = strictSSL;
        self.applicationConfig = applicationConfig;
        self.tokenController = [[KZTokenController alloc] init];
        self.tenantMarketPlace = tenantMarketPlace;
    }
    return self;
}

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
              completion:(void (^)(id))block
{
    self.authCompletionBlock = block;
    self.lastUserName = user;
    self.lastPassword = password;
    self.lastProviderKey = provider;
    
    [self authenticateUser:user withProvider:provider andPassword:password];
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password
{
    self.lastUserName = user;
    self.lastPassword = password;
    self.lastProviderKey = provider;
    
    [self.tokenController loadTokensFromCacheForIpKey:[self getIpCacheKey]
                                       accessTokenKey:[self getAccessTokenCacheKey]];
    
    if (self.tokenController.kzToken && self.tokenController.ipToken) {
        [self completeAuthenticationFlow];
    }
    else {
        [self invokeAuthServices:user withPassword:password andProvider:provider];
    }
}

-(void) invokeAuthServices:(NSString *) user withPassword:(NSString *) password andProvider:(NSString *) providerKey
{
    NSString * authServiceScope = self.applicationConfig.authConfig.authServiceScope;
    NSString * authServiceEndpoint = self.applicationConfig.authConfig.authServiceEndpoint;
    NSString * applicationScope = self.applicationConfig.authConfig.applicationScope;
    
    NSString * providerProtocol = [self.applicationConfig.authConfig protocolForProvider:providerKey];
    NSString * providerIPEndpoint = [self.applicationConfig.authConfig endPointForProvider:providerKey];
    
    
    NSError *authConfigError;
    if (![self.applicationConfig validConfigForProvider:providerKey error:&authConfigError]) {
        self.authCompletionBlock(authConfigError);
        return;
    }
    
    __weak KZApplicationAuthentication *safeMe = self;
    
    if (!self.ip)
        self.ip = [KZIdentityProviderFactory createProvider:providerProtocol strictSSL:self.strictSSL ];
    
    [self.ip initializeWithUserName:user password:password andScope:authServiceScope];
    [self.ip requestToken:providerIPEndpoint completion:^(NSString *ipToken, NSError *error) {
        if (error) {
            if (safeMe.authCompletionBlock) {
                safeMe.authCompletionBlock(error);
                return ;
            }
        }
        
        NSDictionary *params = @{@"wrap_scope": applicationScope,
                                 @"wrap_assertion_format" : @"SAML",
                                 @"wrap_assertion" : ipToken};
        
        [safeMe initializeHttpClient];
        
        [safeMe.defaultClient setBasePath:authServiceEndpoint];
        [safeMe.defaultClient POST:@"" parameters:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode]>300) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                details[NSLocalizedDescriptionKey] = @"KidoZen service returns an invalid response";
                details[@"Error message"] = [error localizedDescription] ? : @"Could not authenticate";
                
                if (safeMe.authCompletionBlock) {
                    safeMe.authCompletionBlock([NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
                }
                
            }
            else {
                safeMe.isAuthenticated = true;
                
                [safeMe.tokenController setAuthenticationResponse:response];
                
                [safeMe.tokenController updateAccessTokenWith:[response objectForKey:@"rawToken"]
                                               accessTokenKey:[safeMe getAccessTokenCacheKey]];
                
                [safeMe.tokenController updateIPTokenWith:ipToken
                                                    ipKey:[safeMe getIpCacheKey]];
                
                [safeMe parseUserInfo:safeMe.tokenController.kzToken];

                [safeMe.tokenController startTokenExpirationTimer:safeMe.kzUser.expiresOn
                                                         callback:^{
                                                             [safeMe tokenExpires];
                                                         }];
                
                if (safeMe.authCompletionBlock) {
                    if (![safeMe.kzUser.claims objectForKey:@"WRAP access_token"] && ![safeMe.kzUser.claims objectForKey:@"ExpiresOn"] )
                    {
                        NSError * err = [[NSError alloc] initWithDomain:@"Authentication" code:0 userInfo:[NSDictionary dictionaryWithObject:@"User is not authenticated" forKey:@"description"]];
                        if (safeMe.authCompletionBlock) {
                            safeMe.authCompletionBlock(err);
                        }
                    }
                    else
                    {
                        if (safeMe.authCompletionBlock) {
                            safeMe.authCompletionBlock(safeMe.kzUser);
                        }
                    }
                }
            }
        }];
    }];
}

- (void)authenticateWithApplicationKey:(NSString *)applicationKey
                 postContentDictionary:(NSDictionary *)postContentDictionary
                              callback:(void(^)(NSString *tokenForProvidedApplicationKey, NSError *error))callback
{
    
    [self initializeHttpClient];
    
    [self.defaultClient setSendParametersAsJSON:YES];
    [self.defaultClient setBasePath:@""];
    
    [self.defaultClient POST:self.applicationConfig.authConfig.oauthTokenEndpoint
                  parameters:postContentDictionary
                  completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                      // Handle error.
                      if ([urlResponse statusCode] > 300) {
                          NSMutableDictionary* details = [NSMutableDictionary dictionary];
                          details[NSLocalizedDescriptionKey] = @"KidoZen service returns an invalid response";
                          details[@"Error message"] = [error localizedDescription] ? : @"Could not authenticate with application key";

                          [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
                          callback(response, [NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
                      }
                      
                      callback(response, nil);
                      
                  }];
}

- (void)doPassiveAuthenticationWithCompletion:(void (^)(id a))block
{
    NSString *passiveUrlString = self.applicationConfig.authConfig.signInUrl;
    NSAssert(passiveUrlString, @"Must not be nil");
    
    self.lastProviderKey = @"SOCIAL";
    
    UIViewController *rootController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    KZPassiveAuthViewController *passiveAuthVC = [[KZPassiveAuthViewController alloc] initWithURLString:passiveUrlString];
    __weak KZApplicationAuthentication *safeMe = self;
    
    self.authCompletionBlock = block;
    
    passiveAuthVC.completion = ^(NSDictionary *fullResponse, NSError *error) {
        if (error != nil) {
            return [safeMe failAuthenticationWithError:error];
        } else {
            [safeMe completePassiveAuthenticationWithResponse:fullResponse];
        }
    };
    
    UINavigationController *webNavigation = [[UINavigationController alloc] initWithRootViewController:passiveAuthVC];
    
    [rootController presentModalViewController:webNavigation animated:YES];
}

- (void)completePassiveAuthenticationWithResponse:(NSDictionary *)jsonDictionary
{

    NSString *token = jsonDictionary[@"access_token"];
    NSString *refreshToken = jsonDictionary[@"refresh_token"];

    [self.tokenController setAuthenticationResponse:jsonDictionary];
    [self.tokenController updateAccessTokenWith:token
                                 accessTokenKey:[self getAccessTokenCacheKey]];
    
    [self.tokenController updateRefreshTokenWith:refreshToken];
    
    self.passiveAuthenticated = YES;
    
    [self completeAuthenticationFlow];
    
}

- (void)handleAuthenticationWithApplicationKey:(NSString *)applicationKey callback:(void(^)(NSError *outerError))callback
{
    self.applicationKey = applicationKey;
    
    __weak KZApplicationAuthentication *safeMe = self;
    [self authenticateWithApplicationKey:applicationKey
                   postContentDictionary:[self dictionaryForTokenUsingApplicationKey]
                                callback:^(id responseForToken, NSError *error) {
                                    
                                    if (error != nil || [responseForToken isKindOfClass:[NSData class]]) {
                                        if (error == nil) {
                                            NSString *message = [responseForToken KZ_UTF8String] ?: @"Error while authenticating with applicationKey.";
                                            error = [NSError errorWithDomain:@""
                                                                        code:0
                                                                    userInfo:@{@"message": message}];
                                        }
                                        
                                        callback(error);
                                        return;
                                    }
                                    
                                    safeMe.lastProviderKey = nil;
                                    safeMe.lastPassword = nil;
                                    safeMe.lastUserName = nil;
                                    
                                    [safeMe.tokenController setAuthenticationResponse:responseForToken];

                                    
                                    [safeMe.tokenController updateAccessTokenWith:responseForToken[kAccessTokenKey]
                                                                   accessTokenKey:[safeMe getAccessTokenCacheKey]];
                                    
                                    [safeMe.tokenController clearIPTokenForKey:[safeMe getIpCacheKey]];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenController.kzToken];
                                    
                                    [safeMe.tokenController startTokenExpirationTimer:safeMe.kzUser.expiresOn
                                                                             callback:^{
                                                                                 [safeMe tokenExpires];
                                                                             }];
                                    
                                    if (callback != nil) {
                                        callback(nil);
                                    }
                                }];
    
}

- (NSDictionary *)dictionaryForTokenUsingApplicationKey
{
    NSMutableDictionary *postContentDictionary = [NSMutableDictionary dictionary];
    
    postContentDictionary[@"client_id"] = self.applicationConfig.domain;
    postContentDictionary[@"client_secret"] = self.applicationKey;
    postContentDictionary[@"grant_type"] = @"client_credentials";
    postContentDictionary[@"scope"] = self.applicationConfig.authConfig.applicationScope;
    
    return postContentDictionary;
}


- (void)refreshPassiveToken
{
    __weak KZApplicationAuthentication *safeMe = self;
    
    [self refreshPassiveToken:^(NSError *error) {
        if (safeMe.authCompletionBlock != nil) {
            if (error != nil) {
                if (safeMe.authCompletionBlock) {
                    safeMe.authCompletionBlock(error);
                }
            } else {
                if (safeMe.authCompletionBlock) {
                    safeMe.authCompletionBlock(safeMe.kzUser);
                }
            }
        }
    }];
    
}

- (void)refreshPassiveToken:(void(^)(NSError *))callback
{
    __weak KZApplicationAuthentication *safeMe = self;
    [self authenticateWithApplicationKey:self.applicationKey
                   postContentDictionary:[self dictionaryForPassiveAuthRefresh]
                                callback:^(id responseForToken, NSError *error) {
                                    
                                    if (error != nil) {
                                        callback(error);
                                    }
                                    
                                    [safeMe.tokenController setAuthenticationResponse:responseForToken];
                                    
                                    [safeMe.tokenController updateAccessTokenWith:responseForToken[kAccessTokenKey]
                                                                   accessTokenKey:[safeMe getAccessTokenCacheKey]];
                                    
                                    [safeMe.tokenController clearIPTokenForKey:[safeMe getIpCacheKey]];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenController.kzToken];
                                    
                                    [safeMe.tokenController startTokenExpirationTimer:safeMe.kzUser.expiresOn
                                                                             callback:^{
                                                                                 [safeMe tokenExpires];
                                                                             }];
                                    
                                    if (callback != nil) {
                                        callback(nil);
                                    }
                                    
                                }];
}

- (NSDictionary *)dictionaryForPassiveAuthRefresh
{
    NSMutableDictionary *postContentDictionary = [NSMutableDictionary dictionary];
    
    postContentDictionary[@"grant_type"] = @"refresh_token";
    postContentDictionary[@"client_id"] = self.applicationConfig.domain;
    postContentDictionary[@"client_secret"] = self.applicationKey;
    postContentDictionary[@"scope"] = self.applicationConfig.authConfig.applicationScope;
    postContentDictionary[@"refresh_token"] = self.tokenController.refreshToken;
    
    return postContentDictionary;
}

-(void) tokenExpires
{
    if (self.tokenExpiresBlock) {
        self.tokenExpiresBlock(self.kzUser);
    } else {
        [self refreshCurrentToken];
    }
}



- (void)refreshCurrentToken
{
    [self.tokenController removeTokensFromCache];
    
    if ([self shouldAuthenticateWithUsernameAndPassword])
    {
        [self authenticateUser:self.lastUserName withProvider:self.lastProviderKey andPassword:self.lastPassword];
    } else if (self.passiveAuthenticated == YES ) {
        [self refreshPassiveToken];
    }
    else {
        [self refreshApplicationKeyToken];
    }

}
- (void)refreshApplicationKeyToken
{
    __weak KZApplicationAuthentication *safeMe = self;
    
    [self handleAuthenticationWithApplicationKey:self.applicationKey callback:^(NSError *error) {
        if (safeMe.authCompletionBlock != nil) {
            if (error != nil) {
                if (safeMe.authCompletionBlock) {
                    safeMe.authCompletionBlock(error);
                }
            } else {
                if (safeMe.authCompletionBlock) {
                    safeMe.authCompletionBlock(safeMe.kzUser);
                }
            }
        }
    }];
    
}

- (BOOL) shouldAuthenticateWithUsernameAndPassword
{
    return (self.lastPassword != nil) && (self.lastUserName != nil) && (self.lastProviderKey != nil);
}

-(void) parseUserInfo:(NSString *) token
{
    self.kzUser = [[KZUser alloc] initWithToken:token];
    self.kzUser.user = self.lastUserName;
    self.kzUser.pass = self.lastPassword;
    self.kzUser.provider = self.lastProviderKey;
    
}


- (void) completeAuthenticationFlow
{
    [self parseUserInfo:self.tokenController.kzToken];
    
    __weak KZApplicationAuthentication *safeMe = self;
    
    if (self.kzUser.expiresOn > 0) {
        [self.tokenController startTokenExpirationTimer:self.kzUser.expiresOn
                                               callback:^{
                                                   [safeMe tokenExpires];
                                               }];
    }
    
    if (self.authCompletionBlock) {
        self.authCompletionBlock(self.tokenController.kzToken);
    }
}

- (void) failAuthenticationWithError:(NSError *)error
{
    if (self.authCompletionBlock) {
        self.authCompletionBlock(error);
    }
}

-(void) initializeHttpClient
{
    if (!self.defaultClient) {
        self.defaultClient = [[SVHTTPClient alloc] init];
        [self.defaultClient setDismissNSURLAuthenticationMethodServerTrust:!self.strictSSL];
    }
}


- (NSString *) getIpCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@-ipToken", self.tenantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword] createHash];
}

- (NSString *) getAccessTokenCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@", self.tenantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword]
            createHash];
}

@end
