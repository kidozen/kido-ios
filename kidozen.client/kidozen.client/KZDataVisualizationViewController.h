//
//  KZDataVizualizationViewController.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/25/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KZApplicationAuthentication;
@class KZApplicationConfiguration;

/*
 * This ViewController contains a webview that displays data visualization
 */
@interface KZDataVisualizationViewController : UIViewController

- (instancetype) initWithApplicationConfig:(KZApplicationConfiguration *)appConfig
                                   appAuth:(KZApplicationAuthentication *)appAuth
                                    tenant:(NSString *)tenant
                                 strictSSL:(BOOL)strictSSL
                               dataVizName:(NSString *)datavizName;


@property (nonatomic, copy) void (^successCb)(void);
@property (nonatomic, copy) void (^errorCb)(NSError *);

@end
