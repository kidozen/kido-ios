//
//  AppDelegate.m
//  GoodSample
//
//  Created by Nicolas Miyasato on 2/17/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "AppDelegate.h"
#import <KZApplication.h>
#import <KZGood.h>

#define kzAppCenterUrl @"https://demo18.kidocloud.com"
#define kzAppName @"tasks"
#define kzApplicationKey @"dooOMoQpfSso3iBCyp/RuimGiKo6RKT8Q9doi6u8Xas="
#define kzUser @"demo18@kidozen.com"
#define kzPassword @"pass"

@interface AppDelegate ()

@property (nonatomic, strong) KZApplication *kzApplication;
@property (nonatomic, strong) KZGood *goodDelegate;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    __weak AppDelegate *safeMe = self;
    
    
    self.kzApplication = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                               applicationName:kzAppName
                                                                applicationKey:kzApplicationKey
                                                                     strictSSL:NO
                                                                   andCallback:^(KZResponse *response)
                               {
                                   
                                   NSAssert(!response.error, @"error must be null");
                                   
                                   [safeMe.kzApplication authenticateUser:kzUser
                                                                  withProvider:@"Kidozen"
                                                                   andPassword:kzPassword
                                                                    completion:^(id kr)
                                    {
                                        NSAssert(![kr  isKindOfClass:[NSError class]], @"error must be null");
                                        safeMe.goodDelegate = [[KZGood alloc] initWithWindow:safeMe.window];
                                        safeMe.kzApplication.gtDelegate = safeMe.goodDelegate;
                                        
                                        safeMe.window.rootViewController.view.userInteractionEnabled = YES;
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

+ (AppDelegate *) sharedDelegate
{
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

@end
