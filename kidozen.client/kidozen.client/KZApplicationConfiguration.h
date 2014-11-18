//
//  KZApplicationConfiguration.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZObject.h"

@class KZAuthenticationConfig;
@class KZResponse;

/*
 * This class holds all information related to the application config.
 * The initial GET request will fill an instance of this class.
 */
@interface KZApplicationConfiguration : KZObject

- (void)setupWithApplicationName:(NSString *)applicationName
                         tennant:(NSString *)tenantMarketPlace
                       strictSSL:(BOOL)strictSSL
                      completion:(void(^)(id configResponse,
                                          NSHTTPURLResponse *configUrlResponse,
                                          NSError *error))cb;

- (BOOL)validConfigForProvider:(NSString *)provider error:(NSError **)error;

@property (nonatomic, copy, readonly) NSString *displayName;
@property (nonatomic, copy, readonly) NSString *customUrl;
@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, readonly) NSNumber *port;
@property (nonatomic, assign, readonly) BOOL published;
@property (nonatomic, copy, readonly) NSString *uploads;
@property (nonatomic, copy, readonly) NSString *tileIcon;
@property (nonatomic, copy, readonly) NSString *tileColor;
@property (nonatomic, copy, readonly) NSString *applicationDescription;
@property (nonatomic, copy, readonly) NSString *shortDescription;
@property (nonatomic, readonly) NSArray *categories;
@property (nonatomic, copy, readonly) NSString *tile;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *gitUrl;
@property (nonatomic, copy, readonly) NSString *ftp;
@property (nonatomic, copy, readonly) NSString *ws;
@property (nonatomic, copy, readonly) NSString *notification;
@property (nonatomic, copy, readonly) NSString *storage;
@property (nonatomic, copy, readonly) NSString *queue;
@property (nonatomic, copy, readonly) NSString *pubsub;
@property (nonatomic, copy, readonly) NSString *config;
@property (nonatomic, copy, readonly) NSString *logging;
@property (nonatomic, copy, readonly) NSString *loggingV3;
@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *sms;
@property (nonatomic, copy, readonly) NSString *service;
@property (nonatomic, copy, readonly) NSString *datasource;
@property (nonatomic, copy, readonly) NSString *files;
@property (nonatomic, copy, readonly) NSString *img;
@property (nonatomic, readonly) NSNumber *rating;
@property (nonatomic, copy, readonly) NSString *html5Url;
@property (nonatomic, readonly) KZAuthenticationConfig *authConfig;

@end
