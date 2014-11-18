//
//  KZApplicationConfiguration.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZApplicationConfiguration.h"
#import "KZResponse.h"
#import "SVHTTPClient.h"
#import "KZAuthenticationConfig.h"
#import "NSData+Conversion.h"

#import <objc/runtime.h>

NSString *const kAppConfigPath = @"/publicapi/apps";
NSString *const kApplicationNameKey = @"name";

@interface KZObject()

@property (nonatomic, strong) NSDictionary *propertiesMapper;

@end

@interface KZApplicationConfiguration()

@property (nonatomic, copy, readwrite) NSString *displayName;
@property (nonatomic, copy, readwrite) NSString *customUrl;
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
@property (nonatomic, strong) KZAuthenticationConfig *authConfig;

@property (nonatomic, strong) SVHTTPClient * httpClient;
@property (nonatomic, assign) BOOL strictSSL;

@end


@implementation KZApplicationConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertiesMapper = @{ @"tile-icon" : @"tileIcon",
                                   @"tile-color" : @"tileColor",
                                   @"description" : @"applicationDescription",
                                   @"logging-v3" : @"loggingV3"};
        
    }
    return self;
}

- (void)setupWithApplicationName:(NSString *)applicationName
                         tennant:(NSString *)tenantMarketPlace
                       strictSSL:(BOOL)strictSSL
                      completion:(void(^)(id configResponse,
                                          NSHTTPURLResponse *configUrlResponse,
                                          NSError *error))cb
{
    
    __weak KZApplicationConfiguration *safeMe = self;
    
    [self initializeHttpClientWithStrictSSL:strictSSL];
    [self.httpClient setBasePath:tenantMarketPlace];

    NSString * appSettingsPath = [NSString stringWithFormat:kAppConfigPath];
    
    [self.httpClient GET:appSettingsPath
              parameters:@{kApplicationNameKey: applicationName}
              completion:^(id configResponse, NSHTTPURLResponse *configUrlResponse, NSError *configError) {
                     
                     // Handle configError
                     if (configError != nil || (configUrlResponse.statusCode != 200) ) {
                         
                         if ([configResponse isKindOfClass:[NSData class]]) {
                             configResponse = [configResponse KZ_UTF8String];
                         }

                         NSError *localError = configError ? : [NSError errorWithDomain:@""
                                                                                   code:configUrlResponse.statusCode
                                                                               userInfo:nil];
                         return cb(configResponse, configUrlResponse, localError);
                         
                     }
                     
                     // Handle case where there is no configuration.
                     if ([configResponse count] == 0) {
                         NSDictionary *userInfo = @{ @"error": @"configResponse dictionary is empty"};
                         
                         NSError *localError = [NSError errorWithDomain:@"KZApplicationError"
                                                              code:0
                                                          userInfo:userInfo];
                         return cb(configResponse, configUrlResponse, localError);
                     }
                     
                     
                     [safeMe configureWithDictionary:[configResponse objectAtIndex:0]];
                     
                     NSError *servicesError = [self validateServices];

                     return cb(configResponse, configUrlResponse, servicesError);
                     
                 }];
    
}


- (BOOL)validConfigForProvider:(NSString *)provider error:(NSError **)error
{
    NSString * authServiceScope = self.authConfig.authServiceScope;
    NSString * authServiceEndpoint = self.authConfig.authServiceEndpoint;
    NSString * applicationScope = self.authConfig.applicationScope;
    
    NSString * providerProtocol = [self.authConfig protocolForProvider:provider];
    NSString * providerIPEndpoint = [self.authConfig endPointForProvider:provider];

    BOOL isValid =  authServiceScope && authServiceEndpoint &&
                    applicationScope && providerProtocol &&
                    providerIPEndpoint && provider;
    
    if (!isValid) {
        *error = [self applicationConfigErrorForProvider:provider];
    }
    
    return isValid;
}

- (NSError *)applicationConfigErrorForProvider:(NSString *)provider
{
    NSString * authServiceScope = self.authConfig.authServiceScope;
    NSString * authServiceEndpoint = self.authConfig.authServiceEndpoint;
    NSString * applicationScope = self.authConfig.applicationScope;
    
    NSString * providerProtocol = [self.authConfig protocolForProvider:provider];
    NSString * providerIPEndpoint = [self.authConfig endPointForProvider:provider];

    NSDictionary *data = @{@"authServiceScope": [NSString stringWithFormat:@"%@", authServiceScope],
                           @"authServiceEndpoint": [NSString stringWithFormat:@"%@", authServiceEndpoint],
                           @"applicationScope": [NSString stringWithFormat:@"%@", applicationScope],
                           @"providerProtocol": [NSString stringWithFormat:@"%@", providerProtocol],
                           @"providerIPEndpoint": [NSString stringWithFormat:@"%@", providerIPEndpoint]};
    
    NSError *error = [[NSError alloc] initWithDomain:@"Application Configuration. Wrong values obtained"
                                                code:1
                                            userInfo:data];
    
    
    return error;
}

-(void) initializeHttpClientWithStrictSSL:(BOOL)strictSSL
{
    if (!self.httpClient) {
        self.httpClient = [[SVHTTPClient alloc] init];
        [self.httpClient setDismissNSURLAuthenticationMethodServerTrust:!strictSSL];
    }
}

- (NSError *) validateServices
{
    if (self.authConfig == nil) {
        return [NSError errorWithDomain:@"KZApplicationConfigurationDomain"
                                   code:0
                               userInfo:@{@"Message"  : @"No authConfig found"}];
        
    }
    if (self.logging == nil) {
        return [NSError errorWithDomain:@"KZApplicationConfigurationDomain"
                                   code:0
                               userInfo:@{@"Message"  : @"No logging service found"}];
    }
    
    if (self.email == nil) {
        return [NSError errorWithDomain:@"KZApplicationConfigurationDomain"
                                   code:0
                               userInfo:@{@"Message"  : @"No email service found"}];
    }
    
    return nil;
}

@end
