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

#import "KZDatasource.h"

@interface MainPassiveAuthViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelClaimName;
@property (strong, nonatomic) KZDatasource *ds;

@end

@implementation MainPassiveAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    NSDictionary *claims = [[AppDelegate sharedDelegate].kzApplication.kzUser claims];
    self.labelClaimName.text= [NSString stringWithFormat:@"Hello: %@",  [claims objectForKey:claimName] ];
}

- (IBAction)queryDS:(id)sender {
    
    self.ds = [[AppDelegate sharedDelegate].kzApplication DataSourceWithName:@"GetCityWeather"];
    [self.ds QueryWithData:@{@"city" : @"Buenos Aires"} completion:^(KZResponse *r) {
        NSLog(@"Response is %@", r.response);
    }];
    
}


@end
