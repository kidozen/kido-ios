//
//  KZPassiveAuthViewController.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/9/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KZPassiveAuthViewController : UIViewController

- (id) initWithURLString:(NSString *)urlString;

@property (nonatomic, copy) void(^completion)(NSString *token, NSString *refreshToken, NSError *error);

@end
