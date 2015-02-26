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

- (IBAction)getKidozenToken:(id)sender {
    __weak ViewController *safeMe = self;
    
    NSString *u = [NSString stringWithFormat:@"https://auth-qa.kidozen.com/v1/armonia/gd?scope=tasks&token=%@", safeMe.textView.text];
    NSURL *url = [NSURL URLWithString:u];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   
    safeMe.textView.text = ret;
    
    
}

- (IBAction)getKidozenStorage:(id)sender {
    __weak ViewController *safeMe = self;
    
    NSString *token = safeMe.textView.text;
    NSError *error = nil;
    
    id obj = [NSJSONSerialization
              JSONObjectWithData:[token dataUsingEncoding:NSUTF8StringEncoding]
              options:0
              error:&error];
    
    token = [obj objectForKey:@"access_token"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://tasks-armonia.kidocloud.com/storage/local"]];
    
    NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", token];
    
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];

    NSURLConnection * con = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [con start];
    
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    __weak ViewController *safeMe = self;

    safeMe.textView.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

@end
