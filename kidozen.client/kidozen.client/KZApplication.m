#import "KZApplication.h"
#import "NSString+Utilities.h"
#import "KZIdentityProviderFactory.h"
#import "NSDictionary+Mongo.h"
#import <UIKit/UIKit.h>

NSString *const KVO_KEY_VALUE = @"kzToken";
NSString *const KVO_NEW_VALUE = @"new";
NSString *const KZ_APP_CONFIG_PATH = @"/publicapi/apps";
NSString *const KZ_SEC_CONFIG_PATH = @"/publicapi/auth/config";

NSString *const IP_KEY_ENDPOINT = @"ipEndpoint";
NSString *const AUTH_SVC_KEY_ENDPOINT = @"authServiceEndpoint";
NSString *const AUTH_SVC_KEY_SCOPE = @"authServiceScope";

NSString *const kAuthConfigKey = @"authConfig";
NSString *const kIdentityProvidersKey = @"identityProviders";
NSString *const kProtocolKey = @"protocol";
NSString *const kApplicationNameKey = @"name";
NSString *const kLoggingKey = @"logging";
NSString *const kEmailKey = @"email";
NSString *const kNotificationKey = @"notification";
NSString *const kDomainKey = @"domain";
NSString *const kOauthTokenEndpointKey = @"oauthTokenEndpoint";
NSString *const kApplicationScopeKey = @"applicationScope";
NSString *const kAccessTokenKey = @"access_token";
NSString *const kURLKey = @"url";

NSString *const kPassiveIdentityProvidersKey = @"passiveIdentityProviders";

NSString *const kPassiveAuthenticationLoginUrlKey = @"loginUrl";

@interface KZApplication ()

@property (nonatomic, copy) NSString *applicationScope;
@property (nonatomic, copy) NSString *oAuthTokenEndPoint;
@property (nonatomic, copy) NSString *domain;

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
@end

@implementation KZApplication

static NSMutableDictionary * staticTokenCache;

- (void) dealloc
{
    [self removeObserver:self forKeyPath:KVO_KEY_VALUE];
}
    

-(id) initWithTennantMarketPlace:(NSString *)tennantMarketPlace
                 applicationName:(NSString *)applicationName
                     andCallback:(void (^)(KZResponse *))callback
{
   return [self initWithTennantMarketPlace:tennantMarketPlace
                           applicationName:applicationName
                                 strictSSL:YES
                               andCallback:callback];
}

-(id) initWithTennantMarketPlace:(NSString *) tennantMarketPlace
                 applicationName:(NSString *) applicationName
                       strictSSL:(BOOL) strictSSL
                     andCallback:(void (^)(KZResponse *))callback
{
    return [self initWithTennantMarketPlace:tennantMarketPlace
                            applicationName:applicationName
                             applicationKey:nil
                                  strictSSL:strictSSL
                                andCallback:callback];
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

                     safeMe.configuration = [NSDictionary dictionaryWithDictionary:[configResponse objectAtIndex:0]];
                     safeMe.securityConfiguration = [NSDictionary dictionaryWithDictionary:self.configuration[kAuthConfigKey]];
                     
                     [safeMe initializeIdentityProviders];
                     [safeMe initializePushNotifications];
                     [safeMe initializeLogging];
                     [safeMe initializeMail];
                     [safeMe initializeApplicationKeysValues];
                     
                     if ([safeMe shouldAskTokenWithForApplicationKey]) {
                         
                         [safeMe handleAuthenticationViaApplicationKeyWithCallback:^(NSError *error){
                             
                             NSError *firstError = configError ?:error;
                             if (firstError != nil) {
                                 [safeMe enableCrashReporter];
                             }
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
    self.crashreporter = [[KZCrashReporter alloc] initWithURLString:self.configuration[kURLKey] withToken:self.kzToken];
}

- (void)disableCrashReporter
{
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

- (void)initializeApplicationKeysValues
{
    self.oAuthTokenEndPoint = self.securityConfiguration[kOauthTokenEndpointKey];
    self.applicationScope = self.securityConfiguration[kApplicationScopeKey];
    self.domain = self.configuration[kDomainKey];
}

- (BOOL)shouldAskTokenWithForApplicationKey
{
    return self.applicationKey != nil && [self.applicationKey length] > 0;
}

- (void)initializeMail
{
    self.mail = [[KZMail alloc] initWithEndpoint:self.configuration[kEmailKey]
                                         andName:nil];
    [self.mail setBypassSSL:self.strictSSL];
    self.mail.kzToken = self.kzToken;
}

- (void) initializeLogging
{
    self.log = [[KZLogging alloc] initWithEndpoint:self.configuration[kLoggingKey]
                                           andName:nil];
    
    [self.log setBypassSSL:self.strictSSL];
    self.log.kzToken = self.kzToken;
}

- (void)initializeIdentityProviders
{
    self.identityProviders = [[NSMutableDictionary alloc] init];
    
    NSDictionary *providerDictionary = self.securityConfiguration[kIdentityProvidersKey];
    
    for(NSString *key in self.securityConfiguration[kIdentityProvidersKey]) {
        NSDictionary *protocolsDictionary = providerDictionary[key];
        NSString *obj = protocolsDictionary[kProtocolKey];
        [self.identityProviders setValue:obj forKey:key];
    }

}

- (void)initializePushNotifications
{
    self.pushNotifications = [[KZNotification alloc] initWithEndpoint:self.configuration[kNotificationKey]
                                                              andName:self.applicationName];
    [self.pushNotifications setBypassSSL:self.strictSSL];
    
}

- (void)handleAuthenticationViaApplicationKeyWithCallback:(void(^)(NSError *))callback
{
    __weak KZApplication *safeMe = self;
    [self authenticateWithApplicationKey:self.applicationKey
                                callback:^(id responseForToken, NSError *error) {
                                    
                                    if (error != nil) {
                                        callback(error);
                                    }
                                    
                                    safeMe.lastProviderKey = nil;
                                    safeMe.lastPassword = nil;
                                    safeMe.lastUserName = nil;
                                    
                                    safeMe.kzToken = responseForToken[kAccessTokenKey];
                                    safeMe.ipToken = @""; // Don't have an identity provider token.
                                    
                                    [safeMe willChangeValueForKey:KVO_KEY_VALUE];
                                    
                                    [safeMe parseUserInfo:safeMe.kzToken];
                                    
                                    [safeMe setCacheWithIPToken:@""
                                                     andKzToken:safeMe.kzToken];
                                    
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
    int timeout = 6;
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
    NSString * authServiceScope = [self.securityConfiguration objectForKey:AUTH_SVC_KEY_SCOPE];
    NSString * authServiceEndpoint = [self.securityConfiguration objectForKey:AUTH_SVC_KEY_ENDPOINT];
    NSString * applicationScope = [self.securityConfiguration objectForKey:kApplicationScopeKey];

    NSDictionary *provider = [[self.securityConfiguration objectForKey:kIdentityProvidersKey] objectForKey:providerKey];
    NSString * providerProtocol = [provider objectForKey:@"protocol"];
    NSString * providerIPEndpoint = [provider objectForKey:@"endpoint"];
    
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
                
                NSString * kzToken = [NSString stringWithFormat:@"WRAP access_token=\"%@\"", [response objectForKey:@"rawToken"]];
                
                [safeMe willChangeValueForKey:KVO_KEY_VALUE];
                
                safeMe.kzToken = kzToken;
                safeMe.ipToken = ipToken;
                
                [safeMe setCacheWithIPToken:ipToken
                                 andKzToken:kzToken];
                
                [safeMe parseUserInfo:kzToken];
                
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
        
        
        // TODO: Have to check for passive authentication.
        if ([self shouldAuthenticateWithUsernameAndPassword])
        {
            [self authenticateUser:self.lastUserName withProvider:self.lastProviderKey andPassword:self.lastPassword];
        } else {
            [self refreshApplicationKeyToken];
        }
    }
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
    NSDictionary *mail = @{@"to": to,
                           @"from" : from,
                           @"subject" : subject,
                           @"bodyHtml": htmlBody,
                           @"bodyText" : textBody};
    
    [self.mail send:mail completion:^(KZResponse * k) {
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
    
    NSString * ep = [self.configuration valueForKey:@"config"] ;
    KZConfiguration * c = [[KZConfiguration alloc] initWithEndpoint:ep andName:name];
    [c setBypassSSL:self.strictSSL];
    c.kzToken = self.kzToken;
    [self.configurations setObject:c forKey:name];
    return c;
}

-(KZSMSSender *) SMSSenderWithNumber:(NSString *) number
{
    NSAssert(self.smssenders, @"Should have already a smsSenders dictionary");

    NSString * ep = [self.configuration valueForKey:@"sms"] ;
    KZSMSSender *s = [[KZSMSSender alloc] initWithEndpoint:ep andName:number];
    [s setBypassSSL:self.strictSSL];
    s.kzToken = self.kzToken;
    [self.smssenders setObject:s forKey:number];
    return s;
}


-(KZQueue *) QueueWithName:(NSString *) name
{
    NSAssert(self.queues, @"Should have already a queues dictionary");

    NSString * ep = [self.configuration valueForKey:@"queue"] ;
    KZQueue * q = [[KZQueue alloc] initWithEndpoint:ep andName:name];
    [q setBypassSSL:self.strictSSL];
    q.kzToken = self.kzToken;
    [self.queues setObject:q forKey:name];
    return q;
}
-(KZStorage *) StorageWithName:(NSString *) name
{
    NSAssert(self.storages, @"Should have already a storages dictionary");

    NSString * ep = [[self.configuration valueForKey:@"storage"] stringByAppendingString:@"/"];
    KZStorage * s= [[KZStorage alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:self.strictSSL];
    s.kzToken = self.kzToken;
    [self.storages setObject:s forKey:name];
    return s;
}
#if TARGET_OS_IPHONE

-(KZPubSubChannel *) PubSubChannelWithName:(NSString *) name
{
    NSAssert(self.channels, @"Should have already a channels dictionary");
    
    NSString * ep = [self.configuration valueForKey:@"pubsub"];
    NSString * wsep = [self.configuration valueForKey:@"ws"];
    KZPubSubChannel * ch =[[KZPubSubChannel alloc] initWithEndpoint:ep wsEndpoint:wsep andName:name];
    [ch setBypassSSL:self.strictSSL];
    ch.kzToken = self.kzToken;
    [self.channels setObject:ch forKey:name];
    return ch;
}

#endif


- (NSDictionary *)dictionaryForTokenUsingApplicationKey
{
    NSMutableDictionary *postContentDictionary = [NSMutableDictionary dictionary];
    
    postContentDictionary[@"client_id"] = self.domain;
    postContentDictionary[@"client_secret"] = self.applicationKey;
    postContentDictionary[@"grant_type"] = @"client_credentials";
    postContentDictionary[@"scope"] = self.applicationScope;
    
    return postContentDictionary;
}

- (void)authenticateWithApplicationKey:(NSString *)applicationKey
                              callback:(void(^)(NSString *tokenForProvidedApplicationKey, NSError *error))callback
{
    
    NSDictionary *postContentDictionary = [self dictionaryForTokenUsingApplicationKey];
    [self initializeHttpClient];

    [self.defaultClient setSendParametersAsJSON:YES];
    [self.defaultClient setBasePath:@""];

    [self.defaultClient POST:self.oAuthTokenEndPoint
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
    NSDictionary *passiveProviderInfo = [self.securityConfiguration[kPassiveIdentityProvidersKey] objectForKey:provider];
    NSString *passiveUrlString = [passiveProviderInfo objectForKey:kPassiveAuthenticationLoginUrlKey];
    NSAssert(passiveUrlString, @"Must not be nil");
    self.lastProviderKey = provider;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:passiveProviderInfo]];
}


- (void)completePassiveAuthenticationWithUrl:(NSURL *)url completion:(void (^)(id))block
{
    self.authCompletionBlock = block;
    
    self.kzToken = [[[[[url fragment] componentsSeparatedByString:@"&"] objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1];
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
    [self parseUserInfo:self.kzToken];
    
    if (self.authCompletionBlock) {
        self.authCompletionBlock(self.kzToken);
    }
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password
{
    self.lastUserName = user;
    self.lastPassword = password;
    self.lastProviderKey = provider;

    [self loadTokensFromCache];
    
    if (self.kzToken && self.ipToken) {
        [self completeAuthenticationFlow];
    }
    else {
        [self invokeAuthServices:user withPassword:password andProvider:provider];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateKZTokenForBaseServices:@[self.queues,
                                         self.storages,
                                         self.configurations,
                                         self.smssenders,
                                         self.channels]
                                change:change];
    
    [self.pushNotifications setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    [self.mail setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    [self.log setKzToken:[change objectForKey:KVO_NEW_VALUE]];
}

- (void)updateKZTokenForBaseServices:(NSArray *)baseServices change:(NSDictionary *)change
{
    for (NSMutableDictionary *serviceDictionary in baseServices) {
        [serviceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[serviceDictionary objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
        }];
    }
}

-(KZDatasource *) DataSourceWithName:(NSString *)name
{
    if (!self.datasources) {
        self.datasources = [[NSMutableDictionary alloc] init];
    }
    NSString * ep =[[self.configuration valueForKey:@"datasource"] stringByAppendingString:@"/"];
    
    KZDatasource * s= [[KZDatasource alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:self.strictSSL];
    
    s.kzToken = self.kzToken;
    s.ipToken = self.ipToken;
    
    [self.datasources setObject:s forKey:name];
    
    return s;
}

-(KZService *) LOBServiceWithName:(NSString *) name
{
    if (!self.services) {
        self.services = [[NSMutableDictionary alloc] init];
    }
    //url: "/api/services/" + name + "/invoke/" + method,
    NSString * ep = [[self.configuration valueForKey:@"url"] stringByAppendingString:
                     [NSString stringWithFormat:@"api/services/%@/",name]];
    
    KZService * s= [[KZService alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:self.strictSSL];
    
    s.kzToken = self.kzToken;
    s.ipToken = self.ipToken;
    
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
     
    self.kzToken = [staticTokenCache objectForKey:kzKey];
    self.ipToken = [staticTokenCache objectForKey:ipKey];

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
