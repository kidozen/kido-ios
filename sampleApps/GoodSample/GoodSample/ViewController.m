//
//  ViewController.m
//  GoodSample
//
//  Created by Nicolas Miyasato on 2/17/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <KZApplication.h>
#import <KZStorage.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *getGDTokenButton;
@property (weak, nonatomic) IBOutlet UIButton *storageButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getToken:(id)sender {
    KZApplication *kzApplication = [AppDelegate sharedDelegate].kzApplication;
    __weak ViewController *safeMe = self;
    
    [kzApplication authenticateWithChallenge:@"challenge"
                                    provider:@"Good"
                                  completion:^(id c) {
                                      
                                      NSAssert(![c  isKindOfClass:[NSError class]], @"error must be null");
                                      safeMe.getGDTokenButton.userInteractionEnabled = NO;
                                      safeMe.textView.text = @"Tap on the Storage Button";
                                      safeMe.storageButton.userInteractionEnabled = YES;
    }];
    
}

- (IBAction)getKidozenStorage:(id)sender {
    KZApplication *kzApplication = [AppDelegate sharedDelegate].kzApplication;

    
    KZStorage *storage = [kzApplication StorageWithName:@"just-in-case"];
    __weak ViewController *safeMe = self;

    NSString * queryString = @"{}";
    [storage query:queryString withBlock:^(KZResponse * r) {
        NSLog(@"response is %@", r);
        safeMe.textView.text = [NSString stringWithFormat:@"%@", r.response];
        
    }];
}

@end
