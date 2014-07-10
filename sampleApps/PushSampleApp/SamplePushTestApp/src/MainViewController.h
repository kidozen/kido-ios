//
//  MainViewController.h
//  SamplePushTestApp
//
//  Created by Nicolas Miyasato on 6/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZApplication;

@interface MainViewController : UIViewController

@property (weak, nonatomic) KZApplication *application;
@property (copy, nonatomic) NSString *deviceToken;

@end
