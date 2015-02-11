//
//  KZAppDelegate.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 2/10/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZAppDelegate.h"
#import "KZResponse.h"
#import "KZApplication.h"
#import "KZUser.h"
#import "KZDeviceInfo.h"

@interface KZAppDelegate()

@end

@implementation KZAppDelegate

- (void) initializeKidozenWithLaunchOptions:(NSDictionary *)launchOptions
                                    success:(void (^)(void))success
                                    failure:(void (^)(KZResponse *))failure
{
    
    [self registerForRemoteNotifications];
    
    __weak KZAppDelegate *safeMe = self;
    
    [self initializeKidozen:^(id response) {

        [safeMe handleLaunchOptions:launchOptions];
        
        if ([response isKindOfClass:[KZUser class]]) {
            if (success != nil) {
                success();
            }
        } else  {
            if (failure != nil) {
                failure(response);
            }
        }
    }];
}


- (void) initializeKidozen:(void (^)(id response))callback  {
    __weak KZAppDelegate *safeMe = self;
    
    self.kzApplication = [[KZApplication alloc] initWithTenantMarketPlace:self.marketPlaceURL
                                                          applicationName:self.applicationName
                                                           applicationKey:self.applicationKey
                                                                strictSSL:self.strictSSL
                                                              andCallback:^(KZResponse *r)
                          {
                              if ([safeMe credentialsAvailable] == YES) {
                                  [safeMe authenticate:callback];
                              } else {
                                  NSLog(@"Warning -- Kidozen is ONLY INITIALIZED, NOT AUTHENTICATED");
                                  if (callback != nil) {
                                      callback(r);
                                  }
                              }
                              
                              
                          }];
}

- (BOOL) credentialsAvailable {
    return  [self.user length] > 0 &&
    [self.password length] > 0 &&
    [self.provider length] > 0;
}

- (void) authenticate:(void (^)(id))callback {
    
    [self.kzApplication authenticateUser:self.user
                            withProvider:self.provider
                             andPassword:self.password
                              completion:^(id response) {
                                  callback(response);
                              }];
}

- (void) handleLaunchOptions:(NSDictionary *)launchOptions
{
    [self handleNotificationEvent:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    
}

- (void) handleNotificationEvent:(NSDictionary *)notificationDictionary {
    
    if (notificationDictionary != nil) {
        [self.kzApplication enableAnalytics];
        
        NSString *deviceUUID = [[KZDeviceInfo sharedDeviceInfo] getUniqueIdentification];
        [self.kzApplication tagEvent:@"notificationOpened" attributes:@{@"uniqueId" : deviceUUID}];
    }
}

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    self.deviceToken = [deviceToken description];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        [self handleNotificationEvent:userInfo];
    }
    
}


- (void) registerForRemoteNotifications {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
@end