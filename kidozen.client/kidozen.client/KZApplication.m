#import "KZApplication.h"
#import "NSString+Utilities.h"
#import "KZIdentityProviderFactory.h"

NSString *const KVO_KEY_VALUE = @"kzToken";
NSString *const KVO_NEW_VALUE = @"new";
NSString *const KZ_APP_CONFIG_PATH = @"/publicapi/apps";
NSString *const KZ_SEC_CONFIG_PATH = @"/publicapi/auth/config";

NSString *const IP_KEY_ENDPOINT = @"ipEndpoint";
NSString *const AUTH_SVC_KEY_ENDPOINT = @"authServiceEndpoint";
NSString *const AUTH_SVC_KEY_SCOPE = @"authServiceScope";


@interface KZApplication ()

@property (nonatomic, copy, readwrite) NSString *applicationKey;

@end

@implementation KZApplication

static NSMutableDictionary * tokenCache;

+ (KZCrashReporter *) sharedCrashReporter {
    static dispatch_once_t once;
    static KZCrashReporter *instance;
    dispatch_once(&once, ^{
        instance = [[KZCrashReporter alloc] init];
    });
    return instance;
}
    
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

-(id) initWithTennantMarketPlace:(NSString *) tennantMarketPlace applicationName:(NSString *) applicationName strictSSL:(BOOL) strictSSL andCallback:(void (^)(KZResponse *))callback
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
        if (!tokenCache) {
            tokenCache = [[NSMutableDictionary alloc] init];
        }
        
        self.applicationKey = applicationKey;
        
        _tennantMarketPlace = [self sanitizeTennantMarketPlace:tennantMarketPlace];
        _applicationName = applicationName;
        _onInitializationComplete = callback;
        _strictSSL = !strictSSL; // negate it to avoid changes in SVHTTPRequest
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

-(void) initializeServices
{
    NSString * appSettingsPath = [NSString stringWithFormat:KZ_APP_CONFIG_PATH];
    if (!_defaultClient) {
        _defaultClient = [[SVHTTPClient alloc] init];
        [_defaultClient setDismissNSURLAuthenticationMethodServerTrust:_strictSSL];
    }

    __weak KZApplication *safeMe = self;
    
    [_defaultClient setBasePath:_tennantMarketPlace];
    [_defaultClient GET:appSettingsPath parameters:[NSDictionary dictionaryWithObjectsAndKeys:_applicationName,@"name", nil]
      completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
          _configuration = [NSDictionary dictionaryWithDictionary:[response objectAtIndex:0]];
          _securityConfiguration = [NSDictionary dictionaryWithDictionary:[_configuration objectForKey:@"authConfig"]];
          _identityProviders = [[NSMutableDictionary alloc] init];
          for(NSString *key in [_securityConfiguration objectForKey:@"identityProviders" ]) {
              NSString * obj = [[[_securityConfiguration objectForKey:@"identityProviders" ] valueForKey:key] valueForKey:@"protocol"] ;
              [_identityProviders setValue:obj forKey:key];
          }
          _pushNotifications = [[KZNotification alloc] initWithEndpoint:[_configuration valueForKey:@"notification"] andName:_applicationName];
          [_pushNotifications setBypassSSL:_strictSSL];
          _log = [[KZLogging alloc] initWithEndpoint:[_configuration valueForKey:@"logging"] andName:nil];
          [_log setBypassSSL:_strictSSL];
          _log.kzToken = safeMe.kzToken;
          _mail = [[KZMail alloc] initWithEndpoint:[_configuration valueForKey:@"email"] andName:nil];
          [_mail setBypassSSL:_strictSSL];
          _mail.kzToken = safeMe.kzToken;
          
          NSString *clientId = _configuration[@"_id"];
          if (safeMe.applicationKey != nil && [safeMe.applicationKey length] > 0) {
              
              [safeMe authenticateWithApplicationKey:safeMe.applicationKey
                                            clientId:clientId
                                            callback:^(NSString *tokenForProvidedApplicationKey, NSError *error) {
                                                
                                                // TODO:
                                                // do something with tokenForProvidedApplicationKey.
                                                
                                                
                                                if (_onInitializationComplete) {
                                                    if (_onInitializationComplete) {
                                                        KZResponse * kzresponse = [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] ;
                                                        [kzresponse setApplication:safeMe];
                                                        _onInitializationComplete (kzresponse);
                                                    }
                                                }
                                            }];
          }
          

      }];
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
    NSString * authServiceScope = [_securityConfiguration objectForKey:AUTH_SVC_KEY_SCOPE];
    NSString * authServiceEndpoint = [_securityConfiguration objectForKey:AUTH_SVC_KEY_ENDPOINT];
    NSString * applicationScope = [_securityConfiguration objectForKey:@"applicationScope"];

    NSDictionary *provider = [[_securityConfiguration objectForKey:@"identityProviders"] objectForKey:providerKey];
    NSString * providerProtocol = [provider objectForKey:@"protocol"];
    NSString * providerIPEndpoint = [provider objectForKey:@"endpoint"];
    
    if (!ip)
        ip = [KZIdentityProviderFactory createProvider:providerProtocol bypassSSL:_strictSSL ];
    
    [ip initializeWithUserName:user password:password andScope:authServiceScope];
    [ip requestToken:providerIPEndpoint completion:^(NSString *ipToken, NSError *error) {
        if (error) {
            if (_authCompletionBlock) {
                _authCompletionBlock(error);
                return ;         
            }
        }
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:applicationScope ,@"wrap_scope", @"SAML",@"wrap_assertion_format", ipToken,@"wrap_assertion", nil];
        
        if (!_defaultClient) {
            _defaultClient = [[SVHTTPClient alloc] init];
            [_defaultClient setDismissNSURLAuthenticationMethodServerTrust:_strictSSL];
        }
        
        [_defaultClient setBasePath:authServiceEndpoint];
        [_defaultClient POST:@"" parameters:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            if ([urlResponse statusCode]>300) {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
              _authCompletionBlock([NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
            }
            else {
                self.isAuthenticated = true;
                self.KidoZenUser.user = user;
                self.KidoZenUser.pass = password;
                
                NSString * kzToken = [NSString stringWithFormat:@"WRAP access_token=\"%@\"", [response objectForKey:@"rawToken"]];
                
                [self willChangeValueForKey:KVO_KEY_VALUE];
                
                self.kzToken = kzToken;
                self.ipToken = ipToken;
                
                [self setCacheWithIPToken:ipToken andKzToken:kzToken];
                
                [self parseUserInfo:kzToken];
                
                if (self.KidoZenUser.expiresOn > 0) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        tokenExpirationTimer = [NSTimer scheduledTimerWithTimeInterval:self.KidoZenUser.expiresOn
                                                                                target:self
                                                                              selector:@selector(tokenExpires:)
                                                                              userInfo:nil
                                                                               repeats:NO];
                        [[NSRunLoop currentRunLoop] addTimer:tokenExpirationTimer forMode:NSDefaultRunLoopMode];
                        [[NSRunLoop currentRunLoop] run];
                    });
                }
                else {
                    NSLog(@"There is a mismatch between your device date and the kidozen authentication service. The expiration time from the service is lower than the device date. The OnSessionExpirationRun method will be ignored");
                }
                if (_authCompletionBlock) {
                    if (![self.KidoZenUser.claims objectForKey:@"system"] && ![self.KidoZenUser.claims objectForKey:@"usersource"] )
                    {
                        NSError * err = [[NSError alloc] initWithDomain:@"Authentication" code:0 userInfo:[NSDictionary dictionaryWithObject:@"User is not authenticated" forKey:@"description"]];
                        _authCompletionBlock(err);
                    }
                    else
                    {
                        _authCompletionBlock(self.KidoZenUser);
                    }
                }
            }
        }];
    }];
}

-(void) tokenExpires:(NSTimer*)theTimer
{
    if (_tokenExpiresBlock) {
        _tokenExpiresBlock(self.KidoZenUser);
    }
    else
    {
        [self removeTokensFromCache];
        [self  authenticateUser:_lastUserName withProvider:_lastProviderKey andPassword:_lastPassword];
    }
}

-(void) sendMailTo:(NSString *)to from:(NSString *) from withSubject:(NSString *) subject andHtmlBody:(NSString *) htmlBody andTextBody:(NSString *)textBody  completion:(void (^)(KZResponse *))block
{
    NSDictionary * mail = [[NSDictionary alloc] initWithObjectsAndKeys:to,@"to", from, @"from", subject, @"subject", htmlBody, @"bodyHtml", textBody, @"bodyText", nil];
    [_mail send:mail completion:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}

-(void) writeLog:(id) message withLevel:(LogLevel) level completion:(void (^)(KZResponse *))block
{
    [_log write:message withLevel:level completion:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}

-(void) clearLog:(void (^)(KZResponse *))block
{
    [_log clear:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}

-(void) allLogMessages:(void (^)(KZResponse *))block
{
    [_log all:^(KZResponse * k) {
        block( [[KZResponse alloc] initWithResponse:k.response urlResponse:k.urlResponse andError:k.error] );
    }];
}


-(KZConfiguration *) ConfigurationWithName:(NSString *) name
{
    if (!_configurations) {
        _configurations = [[NSMutableDictionary alloc] init];
    }
    NSString * ep = [_configuration valueForKey:@"config"] ;
    KZConfiguration * c = [[KZConfiguration alloc] initWithEndpoint:ep andName:name];
    [c setBypassSSL:_strictSSL];
    c.kzToken = self.kzToken;
    [_configurations setObject:c forKey:name];
    return c;
}

-(KZSMSSender *) SMSSenderWithNumber:(NSString *) number
{
    if (!_smssenders) {
        _smssenders = [[NSMutableDictionary alloc] init];
    }
    NSString * ep = [_configuration valueForKey:@"sms"] ;
    KZSMSSender *s = [[KZSMSSender alloc] initWithEndpoint:ep andName:number];
    [s setBypassSSL:_strictSSL];
    s.kzToken = self.kzToken;
    [_smssenders setObject:s forKey:number];
    return s;
}


-(KZQueue *) QueueWithName:(NSString *) name
{
    if (!_queues) {
        _queues = [[NSMutableDictionary alloc] init];
    }
    
    NSString * ep = [_configuration valueForKey:@"queue"] ;
    KZQueue * q = [[KZQueue alloc] initWithEndpoint:ep andName:name];
    [q setBypassSSL:_strictSSL];
    q.kzToken = self.kzToken;
    [_queues setObject:q forKey:name];
    return q;
}
-(KZStorage *) StorageWithName:(NSString *) name
{
    if (!_storages) {
        _storages = [[NSMutableDictionary alloc] init];
    }
    NSString * ep = [[_configuration valueForKey:@"storage"] stringByAppendingString:@"/"];
    KZStorage * s= [[KZStorage alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:_strictSSL];
    s.kzToken = self.kzToken;
    [_storages setObject:s forKey:name];
    return s;
}
#if TARGET_OS_IPHONE

-(KZPubSubChannel *) PubSubChannelWithName:(NSString *) name
{
    if (!_channels) {
        _channels = [[NSMutableDictionary alloc] init];
    }
    
    NSString * ep = [_configuration valueForKey:@"pubsub"];
    NSString * wsep = [_configuration valueForKey:@"ws"];
    KZPubSubChannel * ch =[[KZPubSubChannel alloc] initWithEndpoint:ep wsEndpoint:wsep andName:name];
    [ch setBypassSSL:_strictSSL];
    ch.kzToken = self.kzToken;
    [_channels setObject:ch forKey:name];
    return ch;
}

#endif


- (NSDictionary *)dictionaryForTokenForClientId:(NSString *)clientId
{
    NSMutableDictionary *postContentDictionary = [NSMutableDictionary dictionary];
    
    postContentDictionary[@"client_id"] = [NSString stringWithFormat:@"%@, %@", _tennantMarketPlace, clientId];
    postContentDictionary[@"client_secret"] = self.applicationKey;
    postContentDictionary[@"grant_type"] = @"client_credentials";
    postContentDictionary[@"scope"] = _applicationName;
    
    return postContentDictionary;
}

- (void)authenticateWithApplicationKey:(NSString *)applicationKey
                              clientId:(NSString *)clientId
                              callback:(void(^)(NSString *tokenForProvidedApplicationKey, NSError *error))callback
{
    NSDictionary *postContentDictionary = [self dictionaryForTokenForClientId:clientId];
    
    NSString * tokenPathEndPoint = @"https://tasks.contoso.local.kidozen.com/";
    if (!_defaultClient) {
        _defaultClient = [[SVHTTPClient alloc] init];
        [_defaultClient setDismissNSURLAuthenticationMethodServerTrust:_strictSSL];
    }
    
    [_defaultClient setBasePath:@""];
    NSLog(@"endpoint %@", tokenPathEndPoint);
    NSLog(@"params %@", postContentDictionary);
    [_defaultClient POST:tokenPathEndPoint
              parameters:postContentDictionary
              completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                  // Handle error.
                  if ([urlResponse statusCode] > 300) {
                      NSMutableDictionary* details = [NSMutableDictionary dictionary];
                      [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
                      callback(response, [NSError errorWithDomain:@"KZWRAPv09IdentityProvider" code:[urlResponse statusCode] userInfo:details]);
                  }
                  NSString *str = [[ NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                  NSLog(@"%@", str);
                  // TODO:
                  // we should get here the updated token.
                  // get token.
                  callback(response, nil);
                  
              }];
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password completion:(void (^)(id))block
{
    _authCompletionBlock = block;
    _lastUserName = user;
    _lastPassword = password;
    _lastProviderKey = provider;
    
    [self authenticateUser:user withProvider:provider andPassword:password];
}

-(void) authenticateUser:(NSString *) user withProvider:(NSString *)provider andPassword:(NSString *) password
{
    _lastUserName = user;
    _lastPassword = password;
    _lastProviderKey = provider;

    [self loadTokensFromCache];
    
    if (self.kzToken && self.ipToken) {
        [self parseUserInfo:self.kzToken];
        
        if (_authCompletionBlock) {
            _authCompletionBlock(self.kzToken);
        }
    }
    else {
        [self invokeAuthServices:user withPassword:password andProvider:provider];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [_queues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[_queues objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    }];
    [_storages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[_storages objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    }];
    [_configurations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[_configurations objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    }];
    [_smssenders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[_smssenders objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    }];
    [_channels enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[_channels objectForKey:key] setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    }];
    [_pushNotifications setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    [_mail setKzToken:[change objectForKey:KVO_NEW_VALUE]];
    [_log setKzToken:[change objectForKey:KVO_NEW_VALUE]];
}

-(KZDatasource *) DataSourceWithName:(NSString *)name
{
    if (!_datasources) {
        _datasources = [[NSMutableDictionary alloc] init];
    }
    NSString * ep =[[_configuration valueForKey:@"datasource"] stringByAppendingString:@"/"];
    
    KZDatasource * s= [[KZDatasource alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:_strictSSL];
    
    s.kzToken = self.kzToken;
    s.ipToken = self.ipToken;
    
    [_datasources setObject:s forKey:name];
    
    return s;
}

-(KZService *) LOBServiceWithName:(NSString *) name
{
    if (!_services) {
        _services = [[NSMutableDictionary alloc] init];
    }
    //url: "/api/services/" + name + "/invoke/" + method,
    NSString * ep = [[_configuration valueForKey:@"url"] stringByAppendingString:
                     [NSString stringWithFormat:@"api/services/%@/",name]];
    
    KZService * s= [[KZService alloc] initWithEndpoint:ep andName:name];
    [s setBypassSSL:_strictSSL];
    
    s.kzToken = self.kzToken;
    s.ipToken = self.ipToken;
    
    [_services setObject:s forKey:name];
    
    return s;
}

-(void) setCacheWithIPToken:(NSString *) ipToken andKzToken:(NSString *) kzToken
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
    
    [tokenCache setValue:kzToken forKey:kzKey];
    [tokenCache setValue:ipToken forKey:ipKey];
    
    [self didChangeValueForKey:KVO_KEY_VALUE];
}

-(void) loadTokensFromCache
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
     
    self.kzToken = [tokenCache objectForKey:kzKey];
    self.ipToken = [tokenCache objectForKey:ipKey];

    [self willChangeValueForKey:KVO_KEY_VALUE];
    [self didChangeValueForKey:KVO_KEY_VALUE];
}

-(void) removeTokensFromCache
{
    NSString * kzKey = [self getKzCacheKey];
    NSString * ipKey = [self getIpCacheKey];
    
    [tokenCache removeObjectForKey:kzKey];
    [tokenCache removeObjectForKey:ipKey];
}

- (NSString *) getIpCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@-ipToken", _tennantMarketPlace, _lastProviderKey, _lastUserName, _lastPassword] createHash];
}

- (NSString *) getKzCacheKey
{
    return [[NSString stringWithFormat:@"%@%@%@%@", _tennantMarketPlace, _lastProviderKey, _lastUserName, _lastPassword]
            createHash];
}


@end
