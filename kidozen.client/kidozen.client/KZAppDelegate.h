//
//  KZAppDelegate.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 2/10/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZApplication;
@class KZResponse;

@interface KZAppDelegate : UIResponder 

@property (nonatomic, strong) KZApplication *kzApplication;
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) NSString *marketPlaceURL;
@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *applicationKey;

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *provider;

@property (nonatomic, assign) BOOL notificationsEnabled;
@property (nonatomic, assign) BOOL strictSSL;

@property (nonatomic, copy) NSString *deviceToken;


- (void) initializeKidozenWithLaunchOptions:(NSDictionary *)launchOptions
                               authenticate:(BOOL)authenticate
                                    success:(void (^)(void))success
                                    failure:(void (^)(KZResponse *response))failure;

- (void) didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void) applicationDidBecomeActive;

- (void) registerForRemoteNotifications;

@end
