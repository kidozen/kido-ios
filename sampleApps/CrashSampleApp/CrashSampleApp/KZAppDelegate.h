//
//  KZAppDelegate.h
//  CrashSampleApp
//
//  Created by Nicolas Miyasato on 4/2/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KZApplication;

@interface KZAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) KZApplication *kzApplication;

+ (KZAppDelegate *)sharedDelegate;

@end
