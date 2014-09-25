//
//  KZDataVizualizationViewController.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/25/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZTokenController;

/*
 * This ViewController contains a webview that displays data visualization
 */
@interface KZDataVizualizationViewController : UIViewController

- (id) initWithEndPoint:(NSString *)endPoint
        applicationName:(NSString *)applicationName
             tenantName:(NSString *)tenantName
        tokenController:(KZTokenController *)tokenController;

@end
