//
//  AppDelegate.m
//  DataVizSampleApp
//
//  Created by Nicolas Miyasato on 10/2/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "AppDelegate.h"
#import "InitialViewController.h"
#import <KZApplication.h>

NSString * const kzAppCenterUrl = @"https://loadtests.qa.kidozen.com";
NSString * const kzAppName = @"testexpiration";
NSString * const kzApplicationKey = @"zbOIwN3KhH184K3C12hJle7rMKEmNR1jaheAZKAAhNM=";
NSString * const kUser = @"loadtests@kidozen.com";
NSString * const kPassword = @"pass";

@interface AppDelegate ()

@property (nonatomic, strong) KZApplication *kzApplication;
@property (nonatomic, strong) InitialViewController *initialViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    __weak AppDelegate *safeMe = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    self.initialViewController = [[InitialViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.initialViewController];
    
    
    
    [self.window setRootViewController:navController];
    
    self.kzApplication = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                          applicationName:kzAppName
                                                           applicationKey:kzApplicationKey
                                                                strictSSL:NO
                                                              andCallback:^(KZResponse *r) {
//                                                                  [safeMe.kzApplication doPassiveAuthenticationWithCompletion:^(id a) {
//                                                                      [safeMe.initialViewController enableUserInteraction];
//                                                                      safeMe.initialViewController.kzApplication = safeMe.kzApplication;
//                                                                  }];
//
                                                                  [safeMe.kzApplication authenticateUser:kUser
                                                                                            withProvider:@"Kidozen"
                                                                                             andPassword:kPassword
                                                                                              completion:^(id c) {
                                                                                                  [safeMe.initialViewController enableUserInteraction];
                                                                                                  safeMe.initialViewController.kzApplication = safeMe.kzApplication;

                                                                                              }];
                                                                  
                                                              }];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end


@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
