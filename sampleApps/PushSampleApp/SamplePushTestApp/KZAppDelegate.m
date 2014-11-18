//
//  KZAppDelegate.m
//  SamplePushTestApp
//
//  Created by Nicolas Miyasato on 6/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZAppDelegate.h"
#import <KZApplication.h>
#import "MainViewController.h"

NSString * const kzAppCenterUrl = @"https://your.app.center.url";
NSString * const kzAppName = @"YOUR_APP";
NSString * const kzUser = @"YOU_USER@KIDOZEN.COM";
NSString * const kzPassword = @"YOUR_PASSWORD";
NSString * const kzProvider = @"YOUR_PROVIDER";
NSString * const kzApplicationKey = @"YOUR_PROVIDER_KEY";

@interface KZAppDelegate()

@property (nonatomic, strong) KZApplication *application;
@property (nonatomic, strong) MainViewController *mainViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation KZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.mainViewController = [[MainViewController alloc] init];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    [self initialize];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    self.mainViewController.deviceToken = [deviceToken description];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void) initialize
{
    __weak KZAppDelegate *safeMe = self;
    
    self.application = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                         applicationName:kzAppName
                                                          applicationKey:kzApplicationKey
                                                               strictSSL:NO
                                                             andCallback:^(KZResponse *r) {
                                                                 
                                                                 [safeMe.application authenticateUser:kzUser
                                                                                         withProvider:kzProvider
                                                                                          andPassword:kzPassword
                                                                                           completion:^(id c) {

                                                                     [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                                                                      (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
                                                                     
                                                                     if (r.error == nil) {
                                                                         safeMe.mainViewController.application = safeMe.application;
                                                                         
                                                                         [safeMe.window setRootViewController:safeMe.navigationController];
                                                                     } else {
                                                                         NSString *message = [NSString stringWithFormat:@"%@", r.error];
                                                                         
                                                                         [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                     message:message
                                                                                                    delegate:self
                                                                                           cancelButtonTitle:@"OK"
                                                                                           otherButtonTitles: nil] show];
                                                                     }
                                                                 }];
                                                             }];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = userInfo[@"message"];
    NSString *title = userInfo[@"aps"][@"alert"];
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self initialize];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
