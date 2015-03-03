//
//  KZApplicationAuthentication.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/14/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZTokenController;
@class KZApplicationConfiguration;
@class KZUser;
@class KZTokenController;

/*
 * This class concentrates all authentication methods.
 */
@interface KZApplicationAuthentication : NSObject


@property (nonatomic, copy) void (^tokenExpiresBlock)(id);
@property (nonatomic, copy) void (^authCompletionBlock)(id);
@property (nonatomic, readonly) KZUser *kzUser;
@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, readonly) BOOL passiveAuthenticated;

@property (nonatomic, readonly) KZTokenController *tokenController;


-(id) initWithApplicationConfig:(KZApplicationConfiguration *)applicationConfig
            tenantMarketPlace:(NSString *)tenantMarketPlace
                    strictSSL:(BOOL)strictSSL;

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password
              completion:(void (^)(id))block;

-(void) authenticateUser:(NSString *)user
            withProvider:(NSString *)provider
             andPassword:(NSString *)password;

/**
 *  This way of authenticating is used for GD (Good Technologies) authentication. You
 *  have to provide a challenge and the server to which you are authenticating to.
 *  It'll open up a webview (handled by Good Technologies SDK included in here) and 
 *  there you have to provide your credentials.
 *
 *  @param challenge The challenge with which a token will get generated.
 *  @param provider  The provider you will
 *  @param block     The callback what will get called.
 */
-(void) authenticateWithChallenge:(NSString *)challenge
                         provider:(NSString *)provider
                       completion:(void(^)(id))block;


// Passive authentication, with corresponding applicationKey;
- (void)handleAuthenticationWithApplicationKey:(NSString *)applicationKey
                                      callback:(void(^)(NSError *outerError))callback;

/**
 * Starts a passive authentication flow.
 */
- (void)doPassiveAuthenticationWithCompletion:(void (^)(id a))block;

// Refreshes the current token, which can be the one obtained from authenticathing
// via username/password, passive authentication or via application key.
- (void)refreshCurrentToken;

@end
