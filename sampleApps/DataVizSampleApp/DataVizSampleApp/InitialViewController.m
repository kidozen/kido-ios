//
//  InitialViewController.m
//  DataVizSampleApp
//
//  Created by Nicolas Miyasato on 10/2/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "InitialViewController.h"
#import <KZApplication.h>

@interface InitialViewController ()
@property (weak, nonatomic) IBOutlet UITextField *dataVizNameTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)showButtonPressed:(id)sender {
    NSString *datavizName = self.dataVizNameTextField.text;
    
    if (datavizName.length > 0) {
        [self.kzApplication showDataVisualizationWithName:datavizName sucess:^{
            NSLog(@"yeah.. app loaded");
        } error:^(NSError *error) {
            NSLog(@"Error found... %@", error);
        }];
    }
}

- (void)enableUserInteraction
{
    self.view.userInteractionEnabled = YES;
    [self.activityIndicator stopAnimating];
}
@end
