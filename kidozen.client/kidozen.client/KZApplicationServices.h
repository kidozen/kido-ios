//
//  KZApplicationServices.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/19/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZQueue;
@class KZStorage;
@class KZService;
@class KZConfiguration;
@class KZSMSSender;
@class KZDatasource;
@class KZPubSubChannel;
@class KZApplicationConfiguration;
@class KZTokenController;

@interface KZApplicationServices : NSObject

- (instancetype)initWithApplicationConfig:(KZApplicationConfiguration *)applicationConfig
                          tokenController:(KZTokenController *)tokenController
                                strictSSL:(BOOL)strictSSL;

- (KZQueue *)QueueWithName:(NSString *)name;
- (KZStorage *)StorageWithName:(NSString *)name;
- (KZService *)LOBServiceWithName:(NSString *)name;
- (KZConfiguration *)ConfigurationWithName:(NSString *)name;
- (KZSMSSender *)SMSSenderWithNumber:(NSString *)number;
- (KZDatasource *)DataSourceWithName:(NSString *)name;
- (KZPubSubChannel *)PubSubChannelWithName:(NSString *) name;

@end
