#import "KZApplication.h"
#import "NSString+Utilities.h"
#import "KZIdentityProviderFactory.h"
#import "NSDictionary+Mongo.h"
#import "Base64.h"
#import "KZApplicationConfiguration.h"
#import "KZAuthenticationConfig.h"
#import "KZTokenController.h"
#import "KZPassiveAuthViewController.h"

#import "KZApplicationServices.h"

#import <UIKit/UIKit.h>

NSString *const KZ_APP_CONFIG_PATH = @"/publicapi/apps";
NSString *const KZ_SEC_CONFIG_PATH = @"/publicapi/auth/config";

NSString *const kApplicationNameKey = @"name";

NSString *const kAccessTokenKey = @"access_token";

@interface KZApplication ()

@property (nonatomic, copy, readwrite) NSString *applicationKey;

@property (nonatomic, copy) NSString *tennantMarketPlace;
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *notificationUrl;

@property (nonatomic, assign) id<KZIdentityProvider> ip;

@property (nonatomic, strong) KZCrashReporter *crashreporter;

@property (nonatomic, assign) BOOL passiveAuthenticated;

@property (nonatomic, strong) KZApplicationConfiguration *applicationConfig;

@property (strong, nonatomic) SVHTTPClient * defaultClient;

@property (strong, nonatomic) KZApplicationServices *appServices;

@property (nonatomic, copy) NSString * lastUserName;
@property (nonatomic, copy) NSString * lastPassword;

@end

@implementation KZApplication


-(id) initWithTennantMarketPlace:(NSString *)tennantMarketPlace
                 applicationName:(NSString *)applicationName
                  applicationKey:(NSString *)applicationKey
                       strictSSL:(BOOL)strictSSL
                     andCallback:(void (^)(KZResponse *))callback
{
    self = [super init];
    
    if (self)
    {
        [self validateMarketPlace:tennantMarketPlace
                  applicationName:applicationName
                   applicationKey:applicationKey];
        
        self.applicationKey = applicationKey;
        
        self.tennantMarketPlace = [self sanitizeTennantMarketPlace:tennantMarketPlace];
        self.applicationName = applicationName;
        self.onInitializationComplete = callback;
        self.strictSSL = !strictSSL; // negate it to avoid changes in SVHTTPRequest
        self.passiveAuthenticated = NO;
        
        [self initializeServices];
        self.tokenController = [[KZTokenController alloc] init];

    }
    return self;
    
}


- (void)validateMarketPlace:(NSString *)marketPlaceString applicationName:(NSString *)applicationName applicationKey:(NSString *)appKey
{
    if (marketPlaceString == nil || [marketPlaceString length] == 0 ||
        applicationName == nil || [applicationName length] == 0 ||
        appKey == nil || [appKey length] == 0) {
        
        NSString *message = [NSString stringWithFormat:@"marketPlace is %@, applicationName is %@, appKey is %@", marketPlaceString, applicationName, appKey];
        @throw [NSException exceptionWithName:@"Fail to initialize KZApplication"
                                       reason:@"marketPlace, applicationName and applicationKey are required."
                                     userInfo:@{@"message" : message}];
    }
    
}


#pragma mark private methods
    
-(NSString *)sanitizeTennantMarketPlace:(NSString *)tennant
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet whitespaceCharacterSet];
    [characterSet addCharactersInString:@"/"];
    
    return [tennant stringByTrimmingCharactersInSet:characterSet];
}

- (void) initialzeDefaultHttpClient
{
    if (!self.defaultClient) {
        self.defaultClient = [[SVHTTPClient alloc] init];
        [self.defaultClient setDismissNSURLAuthenticationMethodServerTrust:self.strictSSL];
    }

}

-(void) initializeServices
{
    __weak KZApplication *safeMe = self;
    
    NSString * appSettingsPath = [NSString stringWithFormat:KZ_APP_CONFIG_PATH];
    [self initializeHttpClient];
    
    [self.defaultClient setBasePath:self.tennantMarketPlace];
    
    [self.defaultClient GET:appSettingsPath
                 parameters:@{kApplicationNameKey: self.applicationName}
                 completion:^(NSArray *configResponse, NSHTTPURLResponse *configUrlResponse, NSError *configError) {
                     if (configError != nil) {
                         return [safeMe failInitializationWithError:configError];
                     }
                     
                     if ([configResponse count] == 0) {
                         NSDictionary *userInfo = @{ @"error": @"configResponse dictionary is empty"};
                         
                         NSError *error = [NSError errorWithDomain:@"KZApplicationError"
                                                              code:0
                                                          userInfo:userInfo];
                         return [safeMe failInitializationWithError:error];
                     }
                     
                     NSError *error;
                     safeMe.applicationConfig = [[KZApplicationConfiguration alloc] initWithDictionary:[configResponse objectAtIndex:0]
                                                                                                 error:&error];
                     
                     if (error != nil) {
                         return [safeMe failInitializationWithError:error];
                     }
                     
                     [safeMe configureApplicationServices];
                     
                     if ([safeMe shouldAskTokenWithForApplicationKey]) {
                         
                         [safeMe handleAuthenticationViaApplicationKeyWithCallback:^(NSError *error){
                             
                             NSError *firstError = configError ?:error;
                             [safeMe didFinishInitializationWithResponse:configResponse
                                                             urlResponse:configUrlResponse
                                                                   error:firstError];
                             
                         }];

                     } else {
                         [safeMe didFinishInitializationWithResponse:configResponse
                                                         urlResponse:configUrlResponse
                                                               error:configError];
                     }
      }];
}

- (void) configureApplicationServices
{
    self.appServices = [[KZApplicationServices alloc] initWithApplicationConfig:self.applicationConfig
                                                                tokenController:self.tokenController
                                                                      strictSSL:self.strictSSL];
    
}

- (void) failAuthenticationWithError:(NSError *)error
{
    if (self.authCompletionBlock) {
        self.authCompletionBlock(error);
    }
}

- (void) failInitializationWithError:(NSError *)error
{
    [self didFinishInitializationWithResponse:nil
                                  urlResponse:nil
                                        error:error];
}

- (void)addBreadCrumb:(NSString *)breadCrumb
{
    if (self.crashreporter != nil) {
        [self.crashreporter addBreadCrumb:[breadCrumb stringByAppendingString:@"\n"]];
    }
}

-(void)enableCrashReporter
{
    if (![self.crashreporter isInitialized]) {
        
        if (NSGetUncaughtExceptionHandler() != nil) {
            NSLog(@"Warning -- NSSetUncaughtExceptionHandler is not nil. Overriding will occur");
        }
        
        self.crashreporter = [[KZCrashReporter alloc] initWithURLString:self.applicationConfig.url
                                                        tokenController:self.tokenController];
    }
}

- (BOOL)shouldAskTokenWithForApplicationKey
{
    return self.applicationKey != nil && [self.applicationKey length] > 0;
}

- (void)handleAuthenticationViaApplicationKeyWithCallback:(void(^)(NSError *outerError))callback
{
    __weak KZApplication *safeMe = self;
    [self authenticateWithApplicationKey:self.applicationKey
                   postContentDictionary:[self dictionaryForTokenUsingApplicationKey]
                                callback:^(id responseForToken, NSError *error) {
                                    
                                    if (error != nil) {
                                        callback(error);
                                        return;
                                    }
                                    
                                    safeMe.lastProviderKey = nil;
                                    safeMe.lastPassword = nil;
                                    safeMe.lastUserName = nil;
                                    
                                    [safeMe.tokenController updateAccessTokenWith:responseForToken[kAccessTokenKey]
                                                                  accessTokenKey:[safeMe getAccessTokenCacheKey]];
                                    
                                    [safeMe.tokenController clearIPTokenForKey:[safeMe getIpCacheKey]];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenController.kzToken];
                                    
                                    [safeMe.tokenController startTokenExpirationTimer:safeMe.KidoZenUser.expiresOn
                                                                            callback:^{
                                                                                [safeMe tokenExpires];
                                                                            }];
                                    
                                    if (callback != nil) {
                                        callback(nil);
                                    }
                                }];
    
}

- (void) didFinishInitializationWithResponse:(id)configResponse
                                 urlResponse:(NSHTTPURLResponse *)configUrlResponse
                                       error:(NSError *)error
{
    if (self.onInitializationComplete) {
        if (self.onInitializationComplete) {
            KZResponse *kzresponse = [[KZResponse alloc] initWithResponse:configResponse
                                                              urlResponse:configUrlResponse
                                                                 andError:error];
            [kzresponse setApplication:self];
            self.onInitializationComplete(kzresponse);
        }
    }

}

-(void) registerProviderWithClassName:(NSString *) className andProviderKey:(NSString *) providerKey
{
    //1- add to array
    //http://osmorphis.blogspot.com.ar/2009/05/reflection-in-objective-c.html
    //BOOL conforms = [obj conformsToProtocol:@protocol(MyInterface)];
}
-(void) registerProviderWithInstance:(id) instance andProviderKey:(NSString *) providerKey
{
    //1- add to array
    //http://osmorphis.blogspot.com.ar/2009/05/reflection-in-objective-c.html
    //BOOL conforms = [obj conformsToProtocol:@protocol(MyInterface)];
}

-(void) parseUserInfo:(NSString *) token
{
    self.KidoZenUser = [[KZUser alloc] initWithToken:token];
}


-(void) invokeAuthServices:(NSString *) user withPassword:(NSString *) password andProvider:(NSString *) providerKey
{
    NSString * authServiceScope = self.applicationConfig.authConfig.authServiceScope;
    NSString * authServiceEndpoint = self.applicationConfig.authConfig.authServiceEndpoint;
    NSString * applicationScope = self.applicationConfig.authConfig.applicationScope;

    NSString * providerProtocol = [self.applicationConfig.authConfig protocolForProvider:providerKey];
    NSString * providerIPEndpoint = [self.applicationConfig.authConfig endPointForProvider:providerKey];
    
    __weak KZApplication *safeMe = self;
    
    if (!self.ip)
        self.ip = [KZIdentityProviderFactory createProvider:providerProtocol bypassSSL:self.strictSSL ];
    
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
                [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
              safeMe.authCompletionBlock([NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
            }
            else {
                safeMe.isAuthenticated = true;
                safeMe.KidoZenUser.user = user;
                safeMe.KidoZenUser.pass = password;
                
                [safeMe.tokenController updateAccessTokenWith:[response objectForKey:@"rawToken"]
                                              accessTokenKey:[safeMe getAccessTokenCacheKey]];
                
                [safeMe.tokenController updateIPTokenWith:ipToken
                                                   ipKey:[safeMe getIpCacheKey]];
                
                [safeMe parseUserInfo:safeMe.tokenController.kzToken];
                
                [safeMe.tokenController startTokenExpirationTimer:safeMe.KidoZenUser.expiresOn
                                                        callback:^{
                                                            [safeMe tokenExpires];
                                                        }];
                
                if (safeMe.authCompletionBlock) {
                    if (![safeMe.KidoZenUser.claims objectForKey:@"system"] && ![safeMe.KidoZenUser.claims objectForKey:@"usersource"] )
                    {
                        NSError * err = [[NSError alloc] initWithDomain:@"Authentication" code:0 userInfo:[NSDictionary dictionaryWithObject:@"User is not authenticated" forKey:@"description"]];
                        safeMe.authCompletionBlock(err);
                    }
                    else
                    {
                        safeMe.authCompletionBlock(safeMe.KidoZenUser);
                    }
                }
            }
        }];
    }];
}

-(void) tokenExpires
{
    if (self.tokenExpiresBlock) {
        self.tokenExpiresBlock(self.KidoZenUser);
    }
    else
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
}

- (void)refreshPassiveToken
{
    __weak KZApplication *safeMe = self;
    
    [self refreshPassiveToken:^(NSError *error) {
        if (safeMe.authCompletionBlock != nil) {
            if (error != nil) {
                safeMe.authCompletionBlock(error);
            } else {
                safeMe.authCompletionBlock(safeMe.KidoZenUser);
            }
        }
    }];

}

- (void)refreshPassiveToken:(void(^)(NSError *))callback
{
    __weak KZApplication *safeMe = self;
    [self authenticateWithApplicationKey:self.applicationKey
                   postContentDictionary:[self dictionaryForPassiveAuthRefresh]
                                callback:^(id responseForToken, NSError *error) {
                                    
                                    if (error != nil) {
                                        callback(error);
                                    }
                                    
                                    [safeMe.tokenController updateAccessTokenWith:responseForToken[kAccessTokenKey]
                                                                  accessTokenKey:[safeMe getAccessTokenCacheKey]];
                                    
                                    [safeMe.tokenController clearIPTokenForKey:[safeMe getIpCacheKey]];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenController.kzToken];
                                    
                                    [safeMe.tokenController startTokenExpirationTimer:safeMe.KidoZenUser.expiresOn
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
    
    postContentDictionary[@"refresh_token"] = [self.tokenController.refreshToken base64EncodedString];
    
    return postContentDictionary;
}

- (void)refreshApplicationKeyToken
{
    __weak KZApplication *safeMe = self;
    
    [self handleAuthenticationViaApplicationKeyWithCallback:^(NSError *error) {
        if (safeMe.authCompletionBlock != nil) {
            if (error != nil) {
                safeMe.authCompletionBlock(error);
            } else {
                safeMe.authCompletionBlock(safeMe.KidoZenUser);
            }
        }
    }];

}

- (BOOL) shouldAuthenticateWithUsernameAndPassword
{
    return (self.lastPassword != nil) && (self.lastUserName != nil) && (self.lastProviderKey != nil);
}

-(void) initializeHttpClient
{
    if (!self.defaultClient) {
        self.defaultClient = [[SVHTTPClient alloc] init];
        [self.defaultClient setDismissNSURLAuthenticationMethodServerTrust:self.strictSSL];
    }
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
                          [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
                          callback(response, [NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
                      }
                      
                      callback(response, nil);
                      
                  }];
}

- (void)startPassiveAuthenticationWithCompletion:(void (^)(id))block
{
    NSString *passiveUrlString = self.applicationConfig.authConfig.signInUrl;
    NSAssert(passiveUrlString, @"Must not be nil");
    
    self.lastProviderKey = @"SOCIAL";
    
    UIViewController *rootController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    KZPassiveAuthViewController *passiveAuthVC = [[KZPassiveAuthViewController alloc] initWithURLString:passiveUrlString];
    __weak KZApplication *safeMe = self;
    
    self.authCompletionBlock = block;

    passiveAuthVC.completion = ^(NSString *token, NSString *refreshToken, NSError *error) {
        if (error != nil) {
            return [safeMe failAuthenticationWithError:error];
        } else {
            [safeMe completePassiveAuthenticationWithToken:token refreshToken:refreshToken];
        }
    };
    
    UINavigationController *webNavigation = [[UINavigationController alloc] initWithRootViewController:passiveAuthVC];
    
    [rootController presentModalViewController:webNavigation animated:YES];
}


- (void)completePassiveAuthenticationWithToken:(NSString *)token refreshToken:(NSString *)refreshToken
{
    [self.tokenController updateAccessTokenWith:token
                                accessTokenKey:[self getAccessTokenCacheKey]];
    
    [self.tokenController updateRefreshTokenWith:refreshToken];


    [self completeAuthenticationFlow];
    
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password completion:(void (^)(id))block
{
    self.authCompletionBlock = block;
    self.lastUserName = user;
    self.lastPassword = password;
    self.lastProviderKey = provider;
    
    [self authenticateUser:user withProvider:provider andPassword:password];
}

- (void) completeAuthenticationFlow
{
    self.passiveAuthenticated = YES;
    
    [self parseUserInfo:self.tokenController.kzToken];

    __weak KZApplication *safeMe = self;
    
    if (self.KidoZenUser.expiresOn > 0) {
        [self.tokenController startTokenExpirationTimer:self.KidoZenUser.expiresOn
                                              callback:^{
                                                  [safeMe tokenExpires];
                                              }];
    }

    if (self.authCompletionBlock) {
        self.authCompletionBlock(self.tokenController.kzToken);
    }
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

- (NSString *) getIpCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@-ipToken", self.tennantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword] createHash];
}

- (NSString *) getAccessTokenCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@", self.tennantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword]
            createHash];
}

@end


@implementation KZApplication(Services)

-(KZQueue *) QueueWithName:(NSString *) name
{
    return [self.appServices QueueWithName:name];
}

-(KZStorage *) StorageWithName:(NSString *) name
{
    return [self.appServices StorageWithName:name];
}

-(KZService *) LOBServiceWithName:(NSString *) name
{
    return [self.appServices LOBServiceWithName:name];
}

-(KZConfiguration *) ConfigurationWithName:(NSString *) name
{
    return [self.appServices ConfigurationWithName:name];
}

-(KZSMSSender *) SMSSenderWithNumber:(NSString *) number
{
    return [self.appServices SMSSenderWithNumber:number];
}

-(KZDatasource *) DataSourceWithName:(NSString *)name
{
    return [self.appServices DataSourceWithName:name];
}

#if TARGET_OS_IPHONE

-(KZPubSubChannel *) PubSubChannelWithName:(NSString *) name
{
    return [self.appServices PubSubChannelWithName:name];
}

#endif


#pragma mark - Logging
-(void) writeLog:(id)message
       withLevel:(LogLevel)level
      completion:(void (^)(KZResponse *))block
{
    return [self.appServices writeLog:message
                            withLevel:level
                           completion:block];
}

-(void) clearLog:(void (^)(KZResponse *))block
{
    [self.appServices clearLog:block];
}

-(void) allLogMessages:(void (^)(KZResponse *))block
{
    [self.appServices allLogMessages:block];
}

- (KZLogging *)log
{
    return self.appServices.log;
}

#pragma mark - Email

-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
        completion:(void (^)(KZResponse *))block
{
    [self.appServices sendMailTo:to
                from:from
         withSubject:subject
         andHtmlBody:htmlBody
         andTextBody:textBody
         attachments:nil
          completion:block];
}


-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
       attachments:(NSDictionary *)attachments
        completion:(void (^)(KZResponse *))block
{
    [self.appServices sendMailTo:to
                            from:from
                     withSubject:subject
                     andHtmlBody:htmlBody
                     andTextBody:textBody
                     attachments:attachments
                      completion:block];
}

- (KZMail *)mail
{
    return self.appServices.mail;
}

#pragma mark - PushNotifications

- (KZNotification *)pushNotifications
{
    return self.appServices.pushNotifications;
}

@end