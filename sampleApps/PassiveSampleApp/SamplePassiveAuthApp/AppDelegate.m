//
//  AppDelegate.m
//  SamplePassiveAuthApp
//
//  Created by Nicolas Miyasato on 5/14/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "AppDelegate.h"
#import "KZApplication.h"
#import "InitialViewController.h"
#import "MainPassiveAuthViewController.h"
#import "KZApplicationConfiguration.h"

NSString * const kzAppCenterUrl = @"https://loadtests.qa.kidozen.com";
NSString * const kzAppName = @"tasks";
NSString * const kzApplicationKey = @"NuSSOjO4d/4Zmm+lbG3ntlGkmeHCPn8x20cj82O4bIo=";
//NSString * const kzApplicationKey = @"GZJQetc+VH9JLWoHnLEwlk7tw+XPSniMUSuIzK9kDxE="; tests.qa tasks


//NSString * const kzAppCenterUrl = @"https://tests.qa.kidozen.com";
//NSString * const kzAppName = @"tasks";
//NSString * const kzApplicationKey = @"GZJQetc+VH9JLWoHnLEwlk7tw+XPSniMUSuIzK9kDxE="; // tests.qa tasks

//
//NSString * const kzAppCenterUrl = @"https://armonia.kidocloud.com";
//NSString * const kzAppName = @"tasks";
//NSString * const kzApplicationKey = @"g1M98x5z4ErptQrXGGZ9Djw4yC2nJr8lzpEm6HVQqCc=";



@interface AppDelegate()

@property (nonatomic, strong) InitialViewController *initialViewController;
@property (nonatomic, strong) KZApplication *kzApplication;
@property (nonatomic, strong) MainPassiveAuthViewController *mainPassiveViewController;

@end

@implementation AppDelegate

+ (instancetype) sharedDelegate
{
    return [UIApplication sharedApplication].delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    __weak AppDelegate *safeMe = self;
    self.initialViewController = [[InitialViewController alloc] initWithCompletionBlock:^(id response) {
        if ([response isKindOfClass:[NSError class]]) {
            NSString *message = [NSString stringWithFormat:@"An error occured, %@", response];
            
            [[[UIAlertView alloc] initWithTitle:@"NOT Authenticated"
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
        } else {
            [safeMe finishAuthentication];
        }
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.initialViewController];
    
    
    [self.window setRootViewController:navController];

    self.kzApplication = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                           applicationName:kzAppName
                                                            applicationKey:kzApplicationKey
                                                                 strictSSL:NO
                                                               andCallback:^(KZResponse *r) {
                                                                   if (r.error) {
                                                                       NSString *message = [NSString stringWithFormat:@"The error is %@", r.error];
                                                                       [[[UIAlertView alloc] initWithTitle:@"Error occured."
                                                                                                   message:message
                                                                                                  delegate:nil
                                                                                         cancelButtonTitle:@"OK"
                                                                                         otherButtonTitles: nil] show];
                                                                       
                                                                   } else {
                                                                       [safeMe.initialViewController startInteraction];
                                                                   }
                                                               }];
    
    return YES;
}


- (void)finishAuthentication
{
    UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
    self.mainPassiveViewController = [[MainPassiveAuthViewController alloc] init];
    [nav pushViewController:self.mainPassiveViewController animated:YES];
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

@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
