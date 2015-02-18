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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

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
    
    [kzApplication.gtDelegate getGTToken:@"challenge"
                                  server:@"goodcontrol.kidozen.com"
                                 success:^(NSString *token) {
                                     NSLog(@"THE TOKEN IS %@", token);
                                     safeMe.textView.text = token;
        
                                 } error:^(NSError *error) {
                                     NSLog(@"There was an error dude... %@", error);
                                     safeMe.textView.text = error.localizedDescription;
                                 }];
    
}

@end
