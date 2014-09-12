//
//  KZApplication.h
//  KZApplication
//
//  Created on April 2013
//  Copyright 2013 KidoZen All rights reserved.
//

#import "KZLogging.h"
#import "KZObject.h"

@class KZApplicationConfiguration;
@class KZCrashReporter;
@class KZResponse;
@class KZQueue;
@class KZStorage;
@class KZService;
@class KZConfiguration;
@class KZSMSSender;
@class KZNotification;
@class KZMail;
@class KZDatasource;

#if TARGET_OS_IPHONE
@class KZPubSubChannel;
#endif

typedef void (^AuthCompletionBlock)(id);
typedef void (^TokenExpiresBlock)(id);
typedef void (^InitializationCompleteBlock)(KZResponse *);

/**
 *
 * Main KidoZen application object
 *
 */
@interface KZApplication : KZObject

@property (nonatomic, readonly) KZCrashReporter *crashreporter;
@property (nonatomic, copy) InitializationCompleteBlock onInitializationComplete;
@property (nonatomic, readonly) KZApplicationConfiguration *applicationConfig;

/**
 * Constructor
 *
 * @param tenantMarketPlace The url of the KidoZen marketplace. (Required)
 * @param applicationName The application name (Required)
 * @param applicationKey Is the application key that gives you access to logging services (Required)
 * without username/password authentication.
 * @param strictSSL Whether we want SSL to be bypassed or not,  only use in development (Required)
 * @param callback The ServiceEventListener callback with the operation results (optional)
 */
-(id) initWithTenantMarketPlace:(NSString *)tennantMarketPlace
                applicationName:(NSString *)applicationName
                 applicationKey:(NSString *)applicationKey
                      strictSSL:(BOOL)strictSSL
                    andCallback:(void (^)(KZResponse *))callback;

/**
 * Will create an instance of crash reporter.
 * When initializing KZApplication with an application key, crash reporting
 * will be enabled by default.
 *
 */
- (void)enableCrashReporter;

/*
 * Will send a string when the app crashes.
 * @TODO: Cap to a certain amount of bytes.
 */
- (void)addBreadCrumb:(NSString *)breadCrumb;


@end


#pragma mark - Authentication Related methods

@interface KZApplication(Authentication)

@property (nonatomic, readonly) KZUser *kzUser;
@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, readonly) BOOL passiveAuthenticated;

/*
 * This method will authenticate you to Kidozen. 
 * To check whether the authentication was successful or not, you should check 
 * on the callback type, if it's an NSError, the authentication was not OK.
 * 
 * @param callback can be a KZResponse or an  NSError, whether the authentication
 * was successful or not.
 * 
 */
-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
              completion:(void (^)(id))callback;

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password;


- (void)handleAuthenticationViaApplicationKeyWithCallback:(void(^)(NSError *))callback;

/**
 * Starts a passive authentication flow.
 * @param callback can be a KZResponse or an  NSError, whether the authentication
 * was successful or not.
 */
- (void)doPassiveAuthenticationWithCompletion:(void (^)(id a))callback;

/* If you want to change the authentication callback, you can do so by
 * setting this property.
 */
- (void) setAuthCompletionBlock:(AuthCompletionBlock)authCompletionBlock;

/*
 * This is the callback that will get called when your token expires.
 */
- (void)setTokenExpiresBlock:(TokenExpiresBlock)tokenExpiresBlock;


@end


@interface KZApplication(Services)

/**
 * Creates a new Queue object
 *
 * @param name The name that references the Queue instance
 * @return a new Queue object
 */
- (KZQueue *)QueueWithName:(NSString *)name;

/**
 * Creates a new Storage object
 *
 * @param name The name that references the Storage instance
 * @return a new Storage object
 */
- (KZStorage *)StorageWithName:(NSString *)name;

/**
 * Creates a new LOBService (LineOfBusiness Service) object
 *
 * @param name the service name.
 * @return a new LOBService object
 */
- (KZService *)LOBServiceWithName:(NSString *)name;

/**
 * Creates a new Configuration object
 *
 * @param name The name that references the Configuration instance
 * @return a new Configuration object
 */
- (KZConfiguration *)ConfigurationWithName:(NSString *)name;

/**
 * Creates a new SMSSender object
 *
 * @param number The phone number to send messages.
 * @return a new SMSSender object
 */
- (KZSMSSender *)SMSSenderWithNumber:(NSString *)number;

/**
 * Creates a new DataSource object
 *
 * @param name the service name.
 * @return a new DataSource object
 */
- (KZDatasource *)DataSourceWithName:(NSString *)name;

#if TARGET_OS_IPHONE
/**
 * Creates a new PubSubChannel object
 *
 * @param name The name that references the channel instance
 * @return A new PubSubChannel object
 */
- (KZPubSubChannel *)PubSubChannelWithName:(NSString *)name;
#endif




#pragma mark - Logging

@property (readonly, nonatomic) KZLogging * log;

/**
 * Creates a new entry in the KZApplication log
 *
 * @param object a NSDictionary object with the message to write
 * @param message is the titleMessage that will appear in the market.
 * @param level The log level: Verbose, Information, Warning, Error, Critical
 * @throws Exception
 */
-(void) writeLog:(id)object
         message:(NSString *)message
       withLevel:(LogLevel)level
      completion:(void (^)(KZResponse *))block;

/**
 * Clears the KZApplication log
 *
 * @param callback The callback with the result of the service call */
- (void)clearLog:(void (^)(KZResponse *))block;

/**
 * Creates a new entry in the KZApplication log
 *
 * @param callback The callback with the result of the service call
 */
- (void)allLogMessages:(void (^)(KZResponse *))block;



#pragma mark - Mail

@property (readonly, nonatomic) KZMail * mail;

/**
 * Sends an EMail
 *
 * @param to Destination email address
 * @param from Source email address
 * @param subject The email subject
 * @param htmlBody The email body in HTML format
 * @param textBody The email body
 * @param callback The callback with the result of the service call
 * @throws Exception
 */
-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
        completion:(void (^)(KZResponse *))block;

/**
 * Sends an email with attachments.
 *
 * @param to Destination email address
 * @param from Source email address
 * @param subject The email subject
 * @param htmlBody The email body in HTML format
 * @param textBody The email body
 * @parm attachments is an array with all attachements you want to send.
 * @param callback The callback with the result of the service call
 */
-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
       attachments:(NSDictionary *)attachments
        completion:(void (^)(KZResponse *))block;



#pragma mark - PushNotifications

/**
 * Push notification service main entry point
 *
 * @return The Push notification object that allows to interact with the Apple Push Notification Services (APNS)
 */
@property (readonly, nonatomic) KZNotification * pushNotifications;


#pragma mark - Analytics


- (void)tagClick:(NSString *)buttonName;

- (void)tagView:(NSString *)viewName;

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;

@end
