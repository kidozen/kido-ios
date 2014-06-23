//
//  KZApplicationServices.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/19/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZApplicationServices.h"
#import "KZApplicationConfiguration.h"
#import "KZTokenController.h"

#import "KZStorage.h"
#import "KZQueue.h"
#import "KZService.h"
#import "KZConfiguration.h"
#import "KZSMSSender.h"
#import "KZDatasource.h"
#import "KZPubSubChannel.h"

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

@end
