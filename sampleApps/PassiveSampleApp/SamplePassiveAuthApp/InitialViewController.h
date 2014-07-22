//
//  InitialViewController.h
//  SamplePassiveAuthApp
//
//  Created by Nicolas Miyasato on 6/13/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InitialViewController : UIViewController

- (id) initWithCompletionBlock:(void (^)(id p))block;

- (void) startInteraction;

@end
