//
//  MainViewController.m
//  SamplePushTestApp
//
//  Created by Nicolas Miyasato on 6/26/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "MainViewController.h"
#import "KZApplication.h"
#import "KZNotification.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UITextField *subscribeTextField;
@property (weak, nonatomic) IBOutlet UITextField *unsubscribeTextField;
@property (weak, nonatomic) IBOutlet UITextField *pushTextField;
@property (weak, nonatomic) IBOutlet UILabel *uuid;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;


@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Sample Push Test App";
}


- (IBAction)subscribe:(id)sender {
    __weak MainViewController *safeMe = self;

    [self.application.pushNotifications subscribeDeviceWithToken:[self.deviceToken description]
                                                       toChannel:self.subscribeTextField.text
                                                      completion:^(KZResponse *r) {
                                                          if (r.error == nil) {
                                                              NSString *message = [NSString stringWithFormat:@"Subscribed to %@", self.subscribeTextField.text];
                                                              [safeMe showAlertWith:message title:@"Subscribed!"];
                                                          } else {
                                                              [safeMe showAlertWith:[r.error localizedDescription] title:@"Error found."];
                                                          }
                                                      }];
}

- (IBAction)unsubscribe:(id)sender {
    __weak MainViewController *safeMe = self;

    [self.application.pushNotifications unSubscribeDeviceUsingToken:[self.deviceToken description]
                                                        fromChannel:self.unsubscribeTextField.text
                                                         completion:^(KZResponse *r) {
                                                             if (r.error == nil) {
                                                                 NSString *message = [NSString stringWithFormat:@"Unsubscribed from %@", self.unsubscribeTextField.text];
                                                                 [safeMe showAlertWith:message title:@"Unsubscribed!"];
                                                             } else {
                                                                 [safeMe showAlertWith:[r.error localizedDescription] title:@"Error found."];
                                                             }
    }];
}

- (IBAction)push:(id)sender {
    
    __weak MainViewController *safeMe = self;
    [self.application.pushNotifications pushNotification:@{@"text": self.messageTextField.text,
                                                           @"title" : @"iOS Title",
                                                           @"type" : @"raw"}
                                               InChannel:self.pushTextField.text
                                              completion:^(KZResponse *r) {
                                                  if (r.error == nil) {
                                                      NSString *message = [NSString stringWithFormat:@"Sent push action to server"];
                                                      [safeMe showAlertWith:message title:@"Push action sent!"];
                                                  } else {
                                                      [safeMe showAlertWith:[r.error localizedDescription] title:@"Error found."];
                                                  }
    }];
}

- (IBAction)listChannels:(id)sender {
    __weak MainViewController *safeMe = self;

    [self.application.pushNotifications getSubscriptions:^(KZResponse *r) {
        NSString *message = [NSString stringWithFormat:@"%@", r.response];
        [safeMe showAlertWith:message title:@"Subscribed channels"];
    }];
}

- (void)showAlertWith:(NSString *)message title:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];

}

@end
