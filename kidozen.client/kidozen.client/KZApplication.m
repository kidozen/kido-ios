#import "KZApplication.h"
#import "NSString+Utilities.h"
#import "KZIdentityProviderFactory.h"
#import "NSDictionary+Mongo.h"
#import "Base64.h"
#import "KZApplicationConfiguration.h"
#import "KZAuthenticationConfig.h"
#import "KZTokenController.h"

#import <UIKit/UIKit.h>

NSString *const KVO_KEY_VALUE = @"kzToken";
NSString *const KVO_NEW_VALUE = @"new";
NSString *const KZ_APP_CONFIG_PATH = @"/publicapi/apps";
NSString *const KZ_SEC_CONFIG_PATH = @"/publicapi/auth/config";

NSString *const kProtocolKey = @"protocol";
NSString *const kApplicationNameKey = @"name";

NSString *const kAccessTokenKey = @"access_token";

@interface KZApplication ()

@property (nonatomic, copy, readwrite) NSString *applicationKey;

@property (nonatomic, copy) NSString *tennantMarketPlace;
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *notificationUrl;

@property (nonatomic, strong) NSMutableDictionary *queues;
@property (nonatomic, strong) NSMutableDictionary *configurations;
@property (nonatomic, strong) NSMutableDictionary *storages;
@property (nonatomic, strong) NSMutableDictionary *smssenders;
@property (nonatomic, strong) NSMutableDictionary *channels;
@property (nonatomic, strong) NSMutableDictionary *files;
@property (nonatomic, strong) NSMutableDictionary *services;
@property (nonatomic, strong) NSMutableDictionary *datasources;

@property (nonatomic, assign) id<KZIdentityProvider> ip;
@property (nonatomic, strong) NSTimer *tokenExpirationTimer;

@property (nonatomic, strong) KZCrashReporter *crashreporter;

@property (nonatomic, assign) BOOL passiveAuthenticated;

@property (nonatomic, strong) KZApplicationConfiguration *applicationConfig;

@end

@implementation KZApplication

static NSMutableDictionary * staticTokenCache;

- (void) dealloc
{
    [self removeObserver:self forKeyPath:KVO_KEY_VALUE];
}

-(id) initWithTennantMarketPlace:(NSString *) tennantMarketPlace
                 applicationName:(NSString *)applicationName
                  applicationKey:(NSString *)applicationKey
                       strictSSL:(BOOL)strictSSL
                     andCallback:(void (^)(KZResponse *))callback
{
    self = [super init];
    if (self)
    {
        if (!staticTokenCache) {
            staticTokenCache = [[NSMutableDictionary alloc] init];
        }
        
        self.applicationKey = applicationKey;
        
        self.tennantMarketPlace = [self sanitizeTennantMarketPlace:tennantMarketPlace];
        self.applicationName = applicationName;
        self.onInitializationComplete = callback;
        self.strictSSL = !strictSSL; // negate it to avoid changes in SVHTTPRequest
        self.passiveAuthenticated = NO;
        self.tokenControler = [[KZTokenController alloc] init];
        
        [self initializeServices];
        [self addObserver:self
               forKeyPath:KVO_KEY_VALUE
                  options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                  context:nil];
        
    }
    return self;
    
}

#pragma mark private methods
    
-(NSString *)sanitizeTennantMarketPlace:(NSString *)tennant
{
    NSMutableCharacterSet *characterSet = [NSCharacterSet whitespaceCharacterSet];
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
    [self initializeBaseDictionaryServices];
    
    NSString * appSettingsPath = [NSString stringWithFormat:KZ_APP_CONFIG_PATH];
    [self initializeHttpClient];
    
    [self.defaultClient setBasePath:self.tennantMarketPlace];
    
    [self.defaultClient GET:appSettingsPath
                 parameters:@{kApplicationNameKey: self.applicationName}
                 completion:^(id configResponse, NSHTTPURLResponse *configUrlResponse, NSError *configError) {
                     safeMe.applicationConfig = [[KZApplicationConfiguration alloc] initWithDictionary:[configResponse objectAtIndex:0]];
                     
                     [safeMe initializeIdentityProviders];
                     [safeMe initializePushNotifications];
                     [safeMe initializeLogging];
                     [safeMe initializeMail];
                     
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

-(void)enableCrashReporter
{
    if (![self.crashreporter isInitialized]) {
        self.crashreporter = [[KZCrashReporter alloc] initWithURLString:self.applicationConfig.url
                                                              withToken:self.tokenControler.kzToken];
    }
}

- (void)disableCrashReporter
{
    // We just nilify
    self.crashreporter = nil;
}

- (void)initializeBaseDictionaryServices
{
    self.configurations = [[NSMutableDictionary alloc] init];
    self.smssenders = [[NSMutableDictionary alloc] init];
    self.queues = [[NSMutableDictionary alloc] init];
    self.storages = [[NSMutableDictionary alloc] init];
    self.channels = [[NSMutableDictionary alloc] init];

}

- (BOOL)shouldAskTokenWithForApplicationKey
{
    return self.applicationKey != nil && [self.applicationKey length] > 0;
}

- (void)initializeMail
{
    self.mail = [[KZMail alloc] initWithEndpoint:self.applicationConfig.email
                                         andName:nil];
    self.mail.tokenControler = self.tokenControler;
    [self.mail setBypassSSL:self.strictSSL];
}

- (void) initializeLogging
{
    self.log = [[KZLogging alloc] initWithEndpoint:self.applicationConfig.logging
                                           andName:nil];    
    self.log.tokenControler = self.tokenControler;
    [self.log setBypassSSL:self.strictSSL];
}

- (void)initializeIdentityProviders
{
    self.identityProviders = [[NSMutableDictionary alloc] init];
    
    NSDictionary *providerDictionary = self.applicationConfig.authConfig.identityProviders;
    
    for(NSString *key in providerDictionary) {
        NSDictionary *protocolsDictionary = providerDictionary[key];
        NSString *obj = protocolsDictionary[kProtocolKey];
        [self.identityProviders setValue:obj forKey:key];
    }

}

- (void)initializePushNotifications
{
    self.pushNotifications = [[KZNotification alloc] initWithEndpoint:self.applicationConfig.notification
                                                              andName:self.applicationName];
    self.pushNotifications.tokenControler = self.tokenControler;
    [self.pushNotifications setBypassSSL:self.strictSSL];
    
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
                                    [safeMe.tokenControler updateAccessTokenWith:responseForToken[kAccessTokenKey]];
                                    [safeMe.tokenControler updateIPTokenWith:@""];
                                    
                                    [safeMe willChangeValueForKey:KVO_KEY_VALUE];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenControler.kzToken];
                                    
                                    // TODO: Should be moved to the tokenController
                                    [safeMe setCacheWithIPToken:@""
                                                     andKzToken:safeMe.tokenControler.kzToken];
                                    
                                    [safeMe handleTokenExpiration];
                                    
                                    if (callback != nil) {
                                        callback(nil);
                                    }
                                }];
    
}

- (void)handleTokenExpiration
{
    __block NSTimer *safeToken = self.tokenExpirationTimer;
    __weak KZApplication *safeMe = self;
#ifdef CURRENTLY_TESTING
    int timeout = 6000;
#else
    int timeout = self.KidoZenUser.expiresOn;
#endif
    if (self.KidoZenUser.expiresOn > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            safeToken = [NSTimer scheduledTimerWithTimeInterval:timeout
                                                         target:safeMe
                                                       selector:@selector(tokenExpires:)
                                                       userInfo:nil
                                                        repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:safeToken forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
    else {
        NSLog(@"There is a mismatch between your device date and the kidozen authentication service. The expiration time from the service is lower than the device date. The OnSessionExpirationRun method will be ignored");
    }
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
                
                [safeMe.tokenControler updateAccessTokenWith:[response objectForKey:@"rawToken"]];
                
                [safeMe willChangeValueForKey:KVO_KEY_VALUE];
                
                [safeMe.tokenControler updateIPTokenWith:ipToken];
                
                [safeMe setCacheWithIPToken:ipToken
                                 andKzToken:safeMe.tokenControler.kzToken];
                
                [safeMe parseUserInfo:safeMe.tokenControler.kzToken];
                
                [safeMe handleTokenExpiration];
                
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

-(void) tokenExpires:(NSTimer*)theTimer
{
    if (self.tokenExpiresBlock) {
        self.tokenExpiresBlock(self.KidoZenUser);
    }
    else
    {
        [self removeTokensFromCache];
        
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
                                    
                                    [safeMe.tokenControler updateAccessTokenWith:responseForToken[kAccessTokenKey]];
                                    [safeMe.tokenControler updateIPTokenWith:@""]; // Don't have an identity provider token.
                                    
                                    [safeMe willChangeValueForKey:KVO_KEY_VALUE];
                                    
                                    [safeMe parseUserInfo:safeMe.tokenControler.kzToken];
                                    
                                    [safeMe setCacheWithIPToken:@""
                                                     andKzToken:safeMe.tokenControler.kzToken];
                                    
                                    [safeMe handleTokenExpiration];

                                    if (callback != nil) {
                                        callback(nil);
                                    }
 
                                }];
}

- (NSDictionary *)dictionaryForPassiveAuthRefresh
{
    NSMutableDictionary *postContentDictionary = [NSMutableDictionary dictionary];
    
    postContentDictionary[@"grant_type"] = @"refresh_token";
    postContentDictionary[@"client_id"] = self.applicationName;
    postContentDictionary[@"client_secret"] = self.applicationKey;
    postContentDictionary[@"refresh_token"] = [self.tokenControler.rawAccessToken base64EncodedString];
    
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

-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
        completion:(void (^)(KZResponse *))block
{
    [self sendMailTo:to
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
    NSMutableDictionary *mail = [NSMutableDictionary dictionaryWithDictionary:@{@"to": to,
                                                                                @"from" : from,
                                                                                @"subject" : subject,
                                                                                @"bodyHtml": htmlBody,
                                                                                @"bodyText" : textBody,
                                                                                }];
    
    [self.mail send:mail attachments:attachments completion:^(KZResponse *k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
    
}

-(id) sanitizeLogMessage:(NSObject *)message
{
    NSMutableDictionary *sanitizedDictionary;
    
    if ([message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionaryMessage = (NSDictionary *)message;
        sanitizedDictionary = [NSMutableDictionary dictionary];
        [dictionaryMessage enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]]) {
                key = [key stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            }
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                obj = [self sanitizeLogMessage:obj];
            }
            
            sanitizedDictionary[key] = obj;
            
        }];
    } else {
        return message;
    }
    
    return sanitizedDictionary;
}

-(void) writeLog:(id)message
       withLevel:(LogLevel)level
      completion:(void (^)(KZResponse *))block
{
    if ( [(NSObject *)message isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *)message;
        message = [d dictionaryWithoutDotsInKeys];
    }
    
    [self.log write:message withLevel:level completion:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}

-(void) clearLog:(void (^)(KZResponse *))block
{
    [self.log clear:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}

-(void) allLogMessages:(void (^)(KZResponse *))block
{
    [self.log all:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}


-(KZConfiguration *) ConfigurationWithName:(NSString *) name
{
    NSAssert(self.configurations, @"Should have already a configurations dictionary");
    
    KZConfiguration * c = [[KZConfiguration alloc] initWithEndpoint:self.applicationConfig.config
                                                            andName:name];
    c.tokenControler = self.tokenControler;
    [c setBypassSSL:self.strictSSL];
    [self.configurations setObject:c forKey:name];
    return c;
}

-(KZSMSSender *) SMSSenderWithNumber:(NSString *) number
{
    NSAssert(self.smssenders, @"Should have already a smsSenders dictionary");

    KZSMSSender *s = [[KZSMSSender alloc] initWithEndpoint:self.applicationConfig.sms
                                                   andName:number];
    s.tokenControler = self.tokenControler;
    [s setBypassSSL:self.strictSSL];
    [self.smssenders setObject:s forKey:number];
    return s;
}


-(KZQueue *) QueueWithName:(NSString *) name
{
    NSAssert(self.queues, @"Should have already a queues dictionary");

    KZQueue * q = [[KZQueue alloc] initWithEndpoint:self.applicationConfig.queue
                                            andName:name];
    q.tokenControler = self.tokenControler;
    [q setBypassSSL:self.strictSSL];
    [self.queues setObject:q forKey:name];
    return q;
}
-(KZStorage *) StorageWithName:(NSString *) name
{
    NSAssert(self.storages, @"Should have already a storages dictionary");

    NSString * ep = [self.applicationConfig.storage stringByAppendingString:@"/"];
    KZStorage * s= [[KZStorage alloc] initWithEndpoint:ep andName:name];
    s.tokenControler = self.tokenControler;
    [s setBypassSSL:self.strictSSL];
    [self.storages setObject:s forKey:name];
    return s;
}

#if TARGET_OS_IPHONE

-(KZPubSubChannel *) PubSubChannelWithName:(NSString *) name
{
    NSAssert(self.channels, @"Should have already a channels dictionary");

    KZPubSubChannel * ch =[[KZPubSubChannel alloc] initWithEndpoint:self.applicationConfig.pubsub
                                                         wsEndpoint:self.applicationConfig.ws
                                                            andName:name];
    ch.tokenControler = self.tokenControler;
    [ch setBypassSSL:self.strictSSL];
    [self.channels setObject:ch forKey:name];
    return ch;
}

#endif


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

- (void)startPassiveAuthenticationWithProvider:(NSString *)provider
{
    NSString *passiveUrlString = [self.applicationConfig.authConfig passiveEndPointStringForProvider:provider];
    NSAssert(passiveUrlString, @"Must not be nil");
    
    self.lastProviderKey = provider;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:passiveUrlString]];
}


- (void)completePassiveAuthenticationWithUrl:(NSURL *)url completion:(void (^)(id))block
{
    self.authCompletionBlock = block;
    
    // Should assert the url.
    NSString *token = [[[[[[url fragment] componentsSeparatedByString:@"&"] objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self.tokenControler updateAccessTokenWith:token];

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
    
    [self willChangeValueForKey:KVO_KEY_VALUE];

    [self parseUserInfo:self.tokenControler.kzToken];
    [self setCacheWithIPToken:@""
                   andKzToken:self.tokenControler.kzToken];
    
    [self handleTokenExpiration];

    if (self.authCompletionBlock) {
        self.authCompletionBlock(self.tokenControler.kzToken);
    }
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password
{
    self.lastUserName = user;
    self.lastPassword = password;
    self.lastProviderKey = provider;

    [self loadTokensFromCache];
    
    if (self.tokenControler.kzToken && self.tokenControler.ipToken) {
        [self completeAuthenticationFlow];
    }
    else {
        [self invokeAuthServices:user withPassword:password andProvider:provider];
    }
}


-(KZDatasource *) DataSourceWithName:(NSString *)name
{
    if (!self.datasources) {
        self.datasources = [[NSMutableDictionary alloc] init];
    }
    NSString * ep = [self.applicationConfig.datasource stringByAppendingString:@"/"];

    KZDatasource * s= [[KZDatasource alloc] initWithEndpoint:ep andName:name];
    s.tokenControler = self.tokenControler;
    [s setBypassSSL:self.strictSSL];
    
    [self.datasources setObject:s forKey:name];
    
    return s;
}

-(KZService *) LOBServiceWithName:(NSString *) name
{
    if (!self.services) {
        self.services = [[NSMutableDictionary alloc] init];
    }
    //url: "/api/services/" + name + "/invoke/" + method,
    NSString *ep = [self.applicationConfig.url stringByAppendingString:
    [NSString stringWithFormat:@"api/services/%@/",name]];
    
    KZService * s= [[KZService alloc] initWithEndpoint:ep andName:name];
    s.tokenControler = self.tokenControler;
    [s setBypassSSL:self.strictSSL];
    
    [self.services setObject:s forKey:name];
    
    return s;
}

-(void) setCacheWithIPToken:(NSString *) ipToken andKzToken:(NSString *) kzToken
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
    
    [staticTokenCache setValue:kzToken forKey:kzKey];
    [staticTokenCache setValue:ipToken forKey:ipKey];
    
    [self didChangeValueForKey:KVO_KEY_VALUE];
}

-(void) loadTokensFromCache
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
    
    if (self.tokenControler == nil) {
        self.tokenControler = [[KZTokenController alloc] init];
    }
    
    
    NSString *kzToken = [staticTokenCache objectForKey:kzKey];
    NSString *ipToken = [staticTokenCache objectForKey:ipKey];

    
    
    [self willChangeValueForKey:KVO_KEY_VALUE];
    [self didChangeValueForKey:KVO_KEY_VALUE];
}

-(void) removeTokensFromCache
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
    
    [staticTokenCache removeObjectForKey:kzKey];
    [staticTokenCache removeObjectForKey:ipKey];
}

- (NSString *) getIpCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@-ipToken", self.tennantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword] createHash];
}

- (NSString *) getKzCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@", self.tennantMarketPlace, self.lastProviderKey, self.lastUserName, self.lastPassword]
            createHash];
}

@end
