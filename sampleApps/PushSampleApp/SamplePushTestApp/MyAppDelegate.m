//
//  MyAppDelegate.m
//  SamplePushTestApp
//
//  Created by Nicolas Miyasato on 6/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "MyAppDelegate.h"
#import <KZApplication.h>
#import "MainViewController.h"

NSString * const kzAppCenterUrl = @"";
NSString * const kzAppName = @"";
NSString * const kzUser = @"@kidozen.com";
NSString * const kzPassword = @"";
NSString * const kzProvider = @"";
NSString * const kzApplicationKey = @"";

@interface MyAppDelegate()

@property (nonatomic, strong) MainViewController *mainViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation MyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeCredentials];
    
    __weak MyAppDelegate *safeMe = self;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.mainViewController = [[MainViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];

    [self initializeKidozenWithLaunchOptions:launchOptions
                                      success:^{
                                          safeMe.mainViewController.application = safeMe.kzApplication;
                                          [safeMe.window setRootViewController:safeMe.navigationController];
                                      }
                                      failure:^(KZResponse *response) {
                                          [safeMe handleError:response.error];
                                      }];
    
    return YES;
}

- (void) initializeCredentials {
    self.user = kzUser;
    self.password = kzPassword;
    self.provider = kzProvider;
    self.applicationKey = kzApplicationKey;
    self.applicationName = kzAppName;
    self.marketPlaceURL = kzAppCenterUrl;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [super didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    self.mainViewController.deviceToken = [deviceToken description];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
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
- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [super application:application didReceiveRemoteNotification:userInfo];

    NSLog(@"Received %@", userInfo);
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [super applicationDidBecomeActive];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) handleError:(NSError *)error {
    
    NSString *message = [NSString stringWithFormat:@"%@", error];
    
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];
}
@end
