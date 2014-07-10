//
//  KZMainCrashViewController.m
//  CrashSampleApp
//
//  Created by Nicolas Miyasato on 4/2/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//


#import "MainCrashViewController.h"
#import "Crasher.h"
#import "KZAppDelegate.h"
#import "KZApplication.h"


@interface MainCrashViewController ()

@property (nonatomic, strong) Crasher *sampleCrasher;
@property (weak, nonatomic) IBOutlet UITextField *breadcrumbText;
@property (weak, nonatomic) IBOutlet UILabel *breadcrumbSentText;
@property (assign, nonatomic) int count;

@end

@implementation MainCrashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.sampleCrasher = [[Crasher alloc] init];
    self.count = 0;
}

- (IBAction)crashWithArrayOutOfBounds:(id)sender {
    [self.sampleCrasher crashWithOutOfBounds];
}

- (IBAction)throwException:(id)sender {
    @throw([[NSException alloc] initWithName:@"Crash Test" reason:@"Button pressed!" userInfo:nil]);
}

- (IBAction)createNonExistantXib:(id)sender {
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"NON_EXISTANT_XIB.xib" owner:nil options:nil][0];
    [self.view addSubview:view];
}

- (IBAction)addBreadcrumb:(id)sender {
    NSString *text = self.breadcrumbText.text ?:@"default";
    self.count++;
    self.breadcrumbSentText.text = [NSString stringWithFormat:@"Breacrumb \"%@\" saved. Number of breadcrumbs is %d", text, self.count];

    [[KZAppDelegate sharedDelegate].kzApplication addBreadCrumb:text];
}


@end
