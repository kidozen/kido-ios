//
//  KZAppDelegate.m
//  CrashSampleApp
//
//  Created by Nicolas Miyasato on 4/2/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZAppDelegate.h"
#import "KZApplication.h"
#import "MainCrashViewController.h"

NSString * const kzAppCenterUrl = @"YOUR_APP_CENTER_URL";
NSString * const kzAppName = @"YOUR_APP";
NSString * const kzApplicationKey = @"YOUR_PROVIDER_KEY";

@interface KZAppDelegate()

@property (nonatomic, strong) KZApplication *kzApplication;
@property (nonatomic, strong) MainCrashViewController *mainCrashViewController;

@end

@implementation KZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    __weak KZAppDelegate *safeMe = self;
    // Application will initialize crash reporter by default, as application key is being passed.
    self.kzApplication = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                         applicationName:kzAppName
                                                          applicationKey:kzApplicationKey
                                                               strictSSL:NO
                                                             andCallback:^(KZResponse * r) {
                                                                 if (r.error == nil) {
                                                                     safeMe.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                                                     safeMe.window.backgroundColor = [UIColor whiteColor];
                                                                     [safeMe.window makeKeyAndVisible];
                                                                     
                                                                     safeMe.mainCrashViewController = [[MainCrashViewController alloc] init];
                                                                     
                                                                     UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:safeMe.mainCrashViewController];
                                                                     [safeMe.window setRootViewController:navController];
                                                                     [safeMe.kzApplication enableCrashReporter];
                                                                 } else {
                                                                     NSLog(@"An error happened %@", r.error);
                                                                 }
                                                             }];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"Calling Application Bundle ID: %@", sourceApplication);
    NSLog(@"URL scheme:%@", [url scheme]);
    NSLog(@"URL query: %@", [url query]);
    
    return YES;
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

+ (KZAppDelegate *)sharedDelegate
{
    return  (KZAppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
