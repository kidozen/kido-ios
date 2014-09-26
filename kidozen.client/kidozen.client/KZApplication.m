
#import <UIKit/UIKit.h>

#import "KZApplication.h"
#import "NSString+Utilities.h"
#import "KZIdentityProviderFactory.h"
#import "NSDictionary+Mongo.h"
#import "Base64.h"
#import "KZApplicationConfiguration.h"
#import "KZAuthenticationConfig.h"
#import "KZTokenController.h"
#import "KZPassiveAuthViewController.h"
#import "KZApplicationAuthentication.h"
#import "KZApplicationServices.h"
#import "KZCrashReporter.h"
#import "KZDataVisualizationViewController.h"


@interface KZApplication ()

@property (nonatomic, copy, readwrite) NSString *applicationKey;

@property (nonatomic, copy) NSString *tenantMarketPlace;
@property (nonatomic, copy) NSString *applicationName;

@property (nonatomic, strong) KZCrashReporter *crashreporter;
@property (nonatomic, strong) KZApplicationConfiguration *applicationConfig;
@property (nonatomic, strong) KZApplicationServices *appServices;
@property (nonatomic, strong) KZApplicationAuthentication *appAuthentication;
@property (nonatomic, assign) BOOL strictSSL;

@end

@implementation KZApplication


-(id) initWithTenantMarketPlace:(NSString *)tenantMarketPlace
                applicationName:(NSString *)applicationName
                 applicationKey:(NSString *)applicationKey
                      strictSSL:(BOOL)strictSSL
                    andCallback:(void (^)(KZResponse *))callback
{
    self = [super init];
    
    if (self)
    {
        [self validateMarketPlace:tenantMarketPlace
                  applicationName:applicationName
                   applicationKey:applicationKey];
        
        self.applicationKey = applicationKey;
        
        self.tenantMarketPlace = [self sanitizeTennantMarketPlace:tenantMarketPlace];
        self.applicationName = applicationName;
        self.onInitializationComplete = callback;
        self.strictSSL = strictSSL;
        self.applicationConfig = [[KZApplicationConfiguration alloc] init];
        
        [self initializeServices];

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


-(NSString *)sanitizeTennantMarketPlace:(NSString *)tennant
{
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet whitespaceCharacterSet];
    [characterSet addCharactersInString:@"/"];
    
    return [tennant stringByTrimmingCharactersInSet:characterSet];
}

-(void) initializeServices
{
    __weak KZApplication *safeMe = self;
    
    [self.applicationConfig setupWithApplicationName:self.applicationName
                                             tennant:self.tenantMarketPlace
                                           strictSSL:self.strictSSL
                                          completion:^(id configResponse,
                                                       NSHTTPURLResponse *configUrlResponse,
                                                       NSError *configError)
     {
         if (configError != nil) {
             // We failed... pass the error.
             return [safeMe didFinishInitializationWithResponse:configResponse
                                                    urlResponse:configUrlResponse
                                                          error:configError];
         }
         
         [safeMe configureAuthentication];

         [safeMe configureApplicationServices];
         
         if ([safeMe shouldAskTokenWithForApplicationKey]) {
             
             [safeMe.appAuthentication handleAuthenticationWithApplicationKey:self.applicationKey
                                                                     callback:^(NSError *authError)
              {
                  [safeMe didFinishInitializationWithResponse:configResponse
                                                  urlResponse:configUrlResponse
                                                        error:authError];
              }];
         } else {
             [safeMe didFinishInitializationWithResponse:configResponse
                                             urlResponse:configUrlResponse
                                                   error:configError];
         }
     }];
}

- (void) configureAuthentication
{
    self.appAuthentication = [[KZApplicationAuthentication alloc] initWithApplicationConfig:self.applicationConfig
                                                                        tenantMarketPlace:self.tenantMarketPlace
                                                                                strictSSL:self.strictSSL];
}

- (void) configureApplicationServices
{
    self.appServices = [[KZApplicationServices alloc] initWithApplicationConfig:self.applicationConfig
                                                                tokenController:self.appAuthentication.tokenController
                                                                      strictSSL:self.strictSSL];
    
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
                                                        tokenController:self.appAuthentication.tokenController];
    }
}

- (BOOL)shouldAskTokenWithForApplicationKey
{
    return self.applicationKey != nil && [self.applicationKey length] > 0;
}


- (void) didFinishInitializationWithResponse:(id)configResponse
                                 urlResponse:(NSHTTPURLResponse *)configUrlResponse
                                       error:(NSError *)error
{
    if (self.onInitializationComplete) {
        KZResponse *kzresponse = [[KZResponse alloc] initWithResponse:configResponse
                                                          urlResponse:configUrlResponse
                                                             andError:error];
        [kzresponse setApplication:self];
        self.onInitializationComplete(kzresponse);
    }

}

@end

@implementation KZApplication(Authentication)

- (KZUser *)kzUser
{
    return self.appAuthentication.kzUser;
}

- (BOOL)isAuthenticated
{
    return self.appAuthentication.isAuthenticated;
}

- (BOOL)passiveAuthenticated
{
    return self.appAuthentication.passiveAuthenticated;
}

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
              completion:(void (^)(id))callback
{
    [self.appAuthentication authenticateUser:user
                                withProvider:provider
                                 andPassword:password
                                  completion:callback];
    
}

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
{
    [self.appAuthentication authenticateUser:user
                                withProvider:provider
                                 andPassword:password];
    
}

- (void)handleAuthenticationViaApplicationKeyWithCallback:(void(^)(NSError *))callback
{
    [self.appAuthentication handleAuthenticationWithApplicationKey:self.applicationKey
                                                          callback:callback];
    
}

/**
 * Starts a passive authentication flow.
 */
- (void)doPassiveAuthenticationWithCompletion:(void (^)(id))callback
{
    [self.appAuthentication doPassiveAuthenticationWithCompletion:callback];
    
}

- (void) setAuthCompletionBlock:(AuthCompletionBlock)authCompletionBlock
{
    [self.appAuthentication setAuthCompletionBlock:authCompletionBlock];
}

- (void)setTokenExpiresBlock:(TokenExpiresBlock)tokenExpiresBlock
{
    self.appAuthentication.tokenExpiresBlock = tokenExpiresBlock;
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
-(void) writeLog:(id)object
         message:(NSString *)message
       withLevel:(LogLevel)level
      completion:(void (^)(KZResponse *))block
{
    return [self.appServices write:object
                           message:message
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


@implementation KZApplication(DataVisualization)

- (void)showDataVisualizationWithName:(NSString *)datavizName
{
    KZDataVisualizationViewController *vc = [[KZDataVisualizationViewController alloc] initWithEndPoint:self.applicationConfig.domain
                                                                                             datavizName:datavizName
                                                                                         tokenController:self.appAuthentication.tokenController];
    
    UIViewController *rootController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    UINavigationController *webNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    [rootController presentModalViewController:webNavigation animated:YES];
}

@end