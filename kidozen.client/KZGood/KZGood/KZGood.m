//
//  KZGood.m
//  KZGood
//
//  Created by Nicolas Miyasato on 2/17/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZGood.h"
#import <GD/GDUtility.h>

@interface KZGood() <GDiOSDelegate, GDAuthTokenDelegate>

@property (nonatomic, strong) UIWindow *previousWindow;
@property (nonatomic, strong) GDiOS *good;

@property (nonatomic, assign) BOOL started;

@property (nonatomic, copy) void (^success)(NSString *token);
@property (nonatomic, copy) void (^failure)(NSError *error);

@property (nonatomic, copy) NSString *challenge;
@property (nonatomic, copy) NSString *serverURLString;

@property (nonatomic, strong) GDUtility *utility;

@end

@implementation KZGood

-(instancetype) initWithWindow:(UIWindow *)window
{
    self = [super init];
    if (self) {
        self.previousWindow = window;
        self.started = NO;
    }
    return self;
}

- (void) getGTToken:(NSString *)challenge
             server:(NSString *)serverURLString
            success:(void(^)(NSString *token))success
              error:(void (^)(NSError *error))failure
{
    self.success = success;
    self.failure = failure;
    self.challenge = challenge;
    self.serverURLString = serverURLString;
    
    [[[GDiOS sharedInstance] getWindow] makeKeyAndVisible];
    
    self.good = [GDiOS sharedInstance];
    self.good.delegate = self;
    
    [self.good authorize];
    
}

-(void)handleEvent:(GDAppEvent*)anEvent
{
    /* Called from _good when events occur, such as system startup. */
    NSLog(@"APPLICATION CONFIG IS %@", [GDiOS sharedInstance].getApplicationConfig);
    
    switch (anEvent.type)
    {
        case GDAppEventAuthorized:
        {
            [self onAuthorized:anEvent];
            break;
        }
        case GDAppEventNotAuthorized:
        {
            [self onNotAuthorized:anEvent];
            break;
        }
        case GDAppEventRemoteSettingsUpdate:
        {
            // handle app config changes
            break;
        }
        default:
            NSLog(@"Unhandled Event");
            break;
    }
}

-(void) onNotAuthorized:(GDAppEvent*)anEvent
{
    /* Handle the Good Libraries not authorized event. */
    
    switch (anEvent.code) {
        case GDErrorActivationFailed:
        case GDErrorProvisioningFailed:
        case GDErrorPushConnectionTimeout:
        case GDErrorSecurityError:
        case GDErrorAppDenied:
        case GDErrorBlocked:
        case GDErrorWiped:
        case GDErrorRemoteLockout:
        case GDErrorPasswordChangeRequired: {
            // an condition has occured denying authorization, an application may wish to log these events
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorIdleLockout: {
            // idle lockout is benign & informational
            break;
        }
        default:
            NSAssert(false, @"Unhandled not authorized event");
            break;
    }
}

-(void) onAuthorized:(GDAppEvent*)anEvent
{
    self.utility = [[GDUtility alloc] init];
    self.utility.gdAuthDelegate = self;
    [self.utility getGDAuthToken:self.challenge
                      serverName:self.serverURLString];
    
    
    switch (anEvent.code) {
        case GDErrorNone: {
            if (!self.started) {
                self.started = YES;
                // set the previous window.
                
            }
            break;
        }
        default:
            NSAssert(false, @"Authorized startup with an error");
            break;
    }
}

- (void)onGDAuthTokenSuccess:(NSString*)gdAuthToken {
    [self.previousWindow makeKeyAndVisible];
    
    if (self.success != nil) {
        self.success(gdAuthToken);
    }
}


- (void)onGDAuthTokenFailure:(NSError*) authTokenError {
    [self.previousWindow makeKeyAndVisible];
    
    if (self.failure != nil) {
        self.failure(authTokenError);
    }
}

@end
