//
//  InitialViewController.h
//  DataVizSampleApp
//
//  Created by Nicolas Miyasato on 10/2/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KZApplication;

@interface InitialViewController : UIViewController

@property (nonatomic, weak) KZApplication *kzApplication;

- (void)enableUserInteraction;

@end
