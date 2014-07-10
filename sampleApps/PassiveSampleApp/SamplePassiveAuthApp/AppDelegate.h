//
//  AppDelegate.h
//  SamplePassiveAuthApp
//
//  Created by Nicolas Miyasato on 5/14/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZApplication;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, nonatomic) KZApplication *kzApplication;

+ (instancetype) sharedDelegate;

@end
