//
//  KZApplicationAuthentication.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/14/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZTokenController;
@class KZApplicationConfiguration;

/* 
 * This class concentrates all authentication methods.
 */
@interface KZApplicationAuthentication : NSObject

-(id) initWithTokenController:(KZTokenController *)tokenController
            applicationConfig:(KZApplicationConfiguration *)applicationConfig
            tenantMarketPlace:(NSString *)tenantMarketPlace
                    strictSSL:(BOOL)strictSSL;

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
              completion:(void (^)(id))block;

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password;

// Passive authentication, with corresponding applicationKey;
- (void)handleAuthenticationWithApplicationKey:(NSString *)applicationKey
                                      callback:(void(^)(NSError *outerError))callback;

/**
 * Starts a passive authentication flow.
 */
- (void)doPassiveAuthenticationWithCompletion:(void (^)(id))block;

// Refreshes the current token, which can be the one obtained from authenticathing
// via username/password, passive authentication or via application key.
- (void)refreshCurrentToken;

@property (nonatomic, copy) void (^tokenExpiresBlock)(id);

@property (nonatomic, copy) void (^authCompletionBlock)(id);

@end
