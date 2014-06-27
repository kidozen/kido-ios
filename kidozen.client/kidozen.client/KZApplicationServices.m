//
//  KZApplicationServices.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/19/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZApplicationServices.h"
#import "NSDictionary+Mongo.h"

#import "KZApplicationConfiguration.h"
#import "KZTokenController.h"

#import "KZStorage.h"
#import "KZQueue.h"
#import "KZService.h"
#import "KZConfiguration.h"
#import "KZSMSSender.h"
#import "KZDatasource.h"
#import "KZPubSubChannel.h"
#import "KZLogging.h"
#import "KZMail.h"
#import "KZNotification.h"

@interface KZApplicationServices()

@property (nonatomic, strong) KZApplicationConfiguration *applicationConfig;
@property (nonatomic, strong) KZTokenController *tokenController;
@property (nonatomic, assign) BOOL strictSSL;

@property (nonatomic, strong) NSMutableDictionary *queues;
@property (nonatomic, strong) NSMutableDictionary *configurations;
@property (nonatomic, strong) NSMutableDictionary *storages;
@property (nonatomic, strong) NSMutableDictionary *smssenders;
@property (nonatomic, strong) NSMutableDictionary *channels;
@property (nonatomic, strong) NSMutableDictionary *services;
@property (nonatomic, strong) NSMutableDictionary *datasources;

@property (strong, nonatomic) KZLogging *log;
@property (strong, nonatomic) KZMail *mail;
@property (strong, nonatomic) KZNotification *pushNotifications;

@end

@implementation KZApplicationServices

- (instancetype)initWithApplicationConfig:(KZApplicationConfiguration *)applicationConfig
                          tokenController:(KZTokenController *)tokenController
                                strictSSL:(BOOL)strictSSL
{
    self = [super init];
    if (self) {
        self.applicationConfig = applicationConfig;
        self.strictSSL = strictSSL;
        self.tokenController = tokenController;
        
        self.queues = [[NSMutableDictionary alloc] init];
        self.services = [[NSMutableDictionary alloc] init];
        self.storages = [[NSMutableDictionary alloc] init];
        self.configurations = [[NSMutableDictionary alloc] init];
        self.smssenders = [[NSMutableDictionary alloc] init];
        self.datasources = [[NSMutableDictionary alloc] init];
        self.channels = [[NSMutableDictionary alloc] init];
        
        [self initializeLogging];
        [self initializeMail];
        [self initializePushNotifications];
        
    }
    return self;
}

- (KZQueue *)QueueWithName:(NSString *)name
{
    NSAssert(self.queues, @"Should have already a queues dictionary");
    
    KZQueue * q = [[KZQueue alloc] initWithEndpoint:self.applicationConfig.queue
                                            andName:name];
    q.tokenController = self.tokenController;
    [q setBypassSSL:self.strictSSL];
    [self.queues setObject:q forKey:name];
    return q;
}

- (KZStorage *)StorageWithName:(NSString *)name
{
    NSAssert(self.storages, @"Should have already a storages dictionary");
    
    NSString * ep = [self.applicationConfig.storage stringByAppendingString:@"/"];
    KZStorage * s= [[KZStorage alloc] initWithEndpoint:ep andName:name];
    s.tokenController = self.tokenController;
    [s setBypassSSL:self.strictSSL];
    [self.storages setObject:s forKey:name];
    return s;
}

- (KZService *)LOBServiceWithName:(NSString *)name
{
    if (!self.services) {
        self.services = [[NSMutableDictionary alloc] init];
    }
    //url: "/api/services/" + name + "/invoke/" + method,
    NSString *ep = [self.applicationConfig.url stringByAppendingString:
                    [NSString stringWithFormat:@"api/services/%@/",name]];
    
    KZService * s= [[KZService alloc] initWithEndpoint:ep andName:name];
    s.tokenController = self.tokenController;
    [s setBypassSSL:self.strictSSL];
    
    [self.services setObject:s forKey:name];
    
    return s;
}

- (KZConfiguration *)ConfigurationWithName:(NSString *)name
{
    NSAssert(self.configurations, @"Should have already a configurations dictionary");
    
    KZConfiguration * c = [[KZConfiguration alloc] initWithEndpoint:self.applicationConfig.config
                                                            andName:name];
    c.tokenController = self.tokenController;
    [c setBypassSSL:self.strictSSL];
    [self.configurations setObject:c forKey:name];
    return c;
}

-(KZSMSSender *) SMSSenderWithNumber:(NSString *) number
{

    NSAssert(self.smssenders, @"Should have already a smsSenders dictionary");
    
    KZSMSSender *s = [[KZSMSSender alloc] initWithEndpoint:self.applicationConfig.sms
                                                andName:number];
    s.tokenController = self.tokenController;
    [s setBypassSSL:self.strictSSL];
    [self.smssenders setObject:s forKey:number];
    return s;
}

-(KZDatasource *) DataSourceWithName:(NSString *)name
{
    if (!self.datasources) {
        self.datasources = [[NSMutableDictionary alloc] init];
    }
    NSString * ep = [self.applicationConfig.datasource stringByAppendingString:@"/"];
    
    KZDatasource * s= [[KZDatasource alloc] initWithEndpoint:ep andName:name];
    s.tokenController = self.tokenController;
    [s setBypassSSL:self.strictSSL];
    
    [self.datasources setObject:s forKey:name];
    
    return s;
}

-(KZPubSubChannel *) PubSubChannelWithName:(NSString *) name
{
    NSAssert(self.channels, @"Should have already a channels dictionary");
    
    KZPubSubChannel * ch =[[KZPubSubChannel alloc] initWithEndpoint:self.applicationConfig.pubsub
                                                         wsEndpoint:self.applicationConfig.ws
                                                            andName:name];
    ch.tokenController = self.tokenController;
    [ch setBypassSSL:self.strictSSL];
    [self.channels setObject:ch forKey:name];
    return ch;
}

#pragma mark - Logging

- (void) initializeLogging
{
    self.log = [[KZLogging alloc] initWithEndpoint:self.applicationConfig.loggingV3
                                           andName:nil];
    self.log.tokenController = self.tokenController;
    [self.log setBypassSSL:self.strictSSL];
}

-(void) write:(id)object message:(NSString *)message withLevel:(LogLevel)level completion:(void (^)(KZResponse *))block
{
    if ( [(NSObject *)object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *)object;
        object = [d dictionaryWithoutDotsInKeys];
    }
    
    [self.log write:object message:message withLevel:level completion:^(KZResponse * k) {
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

#pragma mark - Email


- (void)initializeMail
{
    self.mail = [[KZMail alloc] initWithEndpoint:self.applicationConfig.email
                                         andName:nil];
    self.mail.tokenController = self.tokenController;
    [self.mail setBypassSSL:self.strictSSL];
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

#pragma mark - PushNotifications

- (void)initializePushNotifications
{
    self.pushNotifications = [[KZNotification alloc] initWithEndpoint:self.applicationConfig.notification
                                                              andName:self.applicationConfig.name];
    self.pushNotifications.tokenController = self.tokenController;
    [self.pushNotifications setBypassSSL:self.strictSSL];
    
}

@end
