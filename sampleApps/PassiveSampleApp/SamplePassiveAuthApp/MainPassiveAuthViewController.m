//
//  KZMainCrashViewController.m
//  CrashSampleApp
//
//  Created by Nicolas Miyasato on 4/2/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//


#import "MainPassiveAuthViewController.h"
#import "Crasher.h"
#import "AppDelegate.h"
#import "KZApplication.h"
#define claimName @"http%3A%2F%2Fschemas.xmlsoap.org%2Fws%2F2005%2F05%2Fidentity%2Fclaims%2Fname"

@interface MainPassiveAuthViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelClaimName;

@end

@implementation MainPassiveAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    NSDictionary *claims = [[[AppDelegate sharedDelegate].kzApplication KidoZenUser] claims];
    self.labelClaimName.text= [NSString stringWithFormat:@"Hello: %@",  [claims objectForKey:claimName] ];
}


@end
