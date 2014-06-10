//
//  KZPassiveAuthViewController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/9/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZPassiveAuthViewController.h"

@interface KZPassiveAuthViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;

@end

@implementation KZPassiveAuthViewController


- (id) initWithURLString:(NSString *)urlString
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadBarButtonItem];
    [self configureWebView];
    [self loadRequest];
    
}

- (void) configureWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void) loadRequest
{
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:urlRequest];
}

- (void) loadBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self cancelBarButtonItem];
}

-(UIBarButtonItem*) cancelBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                         target:self
                                                         action:@selector(cancelAuth)];
}


- (void)cancelAuth
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] absoluteString] hasPrefix:@"ios:"]) {
        NSString *token = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        if (self.completion != nil) {
            self.completion(token);
            [self dismissModalViewControllerAnimated:YES];
        }
        return NO;
    }
    return YES;
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
}

@end
