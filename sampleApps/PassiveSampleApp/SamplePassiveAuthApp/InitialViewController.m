//
//  InitialViewController.m
//  SamplePassiveAuthApp
//
//  Created by Nicolas Miyasato on 6/13/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "InitialViewController.h"
#import "AppDelegate.h"
#import "KZApplication.h"

@interface InitialViewController ()

@property (nonatomic, copy) void(^passiveCompletionBlock)(id);
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation InitialViewController

- (id) initWithCompletionBlock:(void (^)(id p))block
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.passiveCompletionBlock = block;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Kidozen";
    [self.activityIndicator startAnimating];
    
}

- (IBAction)startPassiveAuthenticationPressed:(id)sender
{
    __weak InitialViewController *safeMe = self;

    [[AppDelegate sharedDelegate].kzApplication doPassiveAuthenticationWithCompletion:^(id p) {
        if (safeMe.passiveCompletionBlock != nil) {
                safeMe.passiveCompletionBlock(p);
            }
        }];

}

- (void) startInteraction
{
    [self.activityIndicator stopAnimating];
}

@end
