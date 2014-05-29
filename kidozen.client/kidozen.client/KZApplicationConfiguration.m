//
//  KZApplicationConfiguration.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZApplicationConfiguration.h"
#import <objc/runtime.h>

@interface KZApplicationConfiguration()

@property (nonatomic, copy, readwrite) NSString *displayName;
@property (nonatomic, copy, readwrite) NSString *domain;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, strong) NSNumber *port;
@property (nonatomic, assign, readwrite) BOOL published;
@property (nonatomic, copy, readwrite) NSString *uploads;
@property (nonatomic, copy, readwrite) NSString *tileIcon;
@property (nonatomic, copy, readwrite) NSString *tileColor;
@property (nonatomic, copy, readwrite) NSString *applicationDescription;
@property (nonatomic, copy, readwrite) NSString *shortDescription;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, copy, readwrite) NSString *tile;
@property (nonatomic, copy, readwrite) NSString *url;
@property (nonatomic, copy, readwrite) NSString *gitUrl;
@property (nonatomic, copy, readwrite) NSString *ftp;
@property (nonatomic, copy, readwrite) NSString *ws;
@property (nonatomic, copy, readwrite) NSString *notification;
@property (nonatomic, copy, readwrite) NSString *storage;
@property (nonatomic, copy, readwrite) NSString *queue;
@property (nonatomic, copy, readwrite) NSString *pubsub;
@property (nonatomic, copy, readwrite) NSString *config;
@property (nonatomic, copy, readwrite) NSString *logging;
@property (nonatomic, copy, readwrite) NSString *email;
@property (nonatomic, copy, readwrite) NSString *sms;
@property (nonatomic, copy, readwrite) NSString *service;
@property (nonatomic, copy, readwrite) NSString *datasource;
@property (nonatomic, copy, readwrite) NSString *files;
@property (nonatomic, copy, readwrite) NSString *img;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, copy, readwrite) NSString *html5Url;
@property (nonatomic, strong) NSArray *authConfig;

@property (nonatomic, strong) NSDictionary *propertiesMapper;

@end


@implementation KZApplicationConfiguration


- (id)initWithDictionary:(NSDictionary *)configDictionary
{
    self = [super init];
    if (self) {
        self.propertiesMapper = @{ @"tile-icon" : @"tileIcon",
                                   @"tile-color" : @"tileColor",
                                   @"description" : @"applicationDescription"};
        
        [self initializeWithDictionary:configDictionary];
        
    }
    return self;
}

- (void) initializeWithDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary allKeys]) {

        NSString *mappedKey = [self.propertiesMapper objectForKey:key] ?: key;
        @try {
            [self setValue:dictionary[key] forKey:mappedKey];
        }
        @catch (NSException *exception) {
            NSLog(@"The proerty %@ does not exist", key);
        }
    }
    
    NSLog(@"%d", self.published);

}
@end
