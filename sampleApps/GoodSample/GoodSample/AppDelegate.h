//
//  AppDelegate.h
//  GoodSample
//
//  Created by Nicolas Miyasato on 2/17/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZApplication;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) KZApplication *kzApplication;

@end

