//
//  KZApplicationServices.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/19/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZLogging.h"

@class KZQueue;
@class KZStorage;
@class KZService;
@class KZConfiguration;
@class KZSMSSender;
@class KZDatasource;
@class KZPubSubChannel;
@class KZApplicationConfiguration;
@class KZTokenController;
@class KZResponse;
@class KZMail;
@class KZNotification;

/*
 * The main idea of this class is to handle everything related to Logging,
 * Email, notifications, SMS, etc...
 */
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

#if TARGET_OS_IPHONE
- (KZPubSubChannel *)PubSubChannelWithName:(NSString *) name;
#endif

#pragma mark - Logging

- (void)write:(id)object message:(NSString *)message withLevel:(LogLevel)level completion:(void (^)(KZResponse *))block;
- (void)clearLog:(void (^)(KZResponse *))block;
- (void)allLogMessages:(void (^)(KZResponse *))block;
- (KZLogging *)log;


#pragma mark - Analytics

- (void)tagClick:(NSString *)buttonName;

- (void)tagView:(NSString *)viewName;

- (void) tagEvent:(NSString *)customEventName
       attributes:(NSDictionary *)attributes;

#pragma mark - Email

-(void) sendMailTo:(NSString *)to
              from:(NSString *)from
       withSubject:(NSString *)subject
       andHtmlBody:(NSString *)htmlBody
       andTextBody:(NSString *)textBody
       attachments:(NSDictionary *)attachments
        completion:(void (^)(KZResponse *))block;

- (KZMail *)mail;



#pragma mark - PushNotifications

- (KZNotification *)pushNotifications;

@end
