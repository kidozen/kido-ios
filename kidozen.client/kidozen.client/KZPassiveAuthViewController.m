//
//  KZPassiveAuthViewController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 6/9/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZPassiveAuthViewController.h"
#import "Base64.h"

#define SUCCESS_PAYLOAD_PREFIX @"Success payload="

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
    return YES;
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *payload = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if ([payload hasPrefix:SUCCESS_PAYLOAD_PREFIX]) {
        NSString *b64 = [payload stringByReplacingOccurrencesOfString:SUCCESS_PAYLOAD_PREFIX withString:@""];
        NSString *json = [b64 base64DecodedString];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:nil
                                                                         error:nil];
        if (self.completion != nil) {
            self.completion(jsonDictionary[@"access_token"]);
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
}

@end
