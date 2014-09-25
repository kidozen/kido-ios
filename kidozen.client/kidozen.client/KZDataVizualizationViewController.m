//
//  KZDataVizualizationViewController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/25/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDataVizualizationViewController.h"
#import "KZTokenController.h"
#import "SVHTTPRequest.h"

@interface KZDataVizualizationViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *downloadURLString;

@property (nonatomic, copy) NSString *applicationName;
@property (nonatomic, copy) NSString *tenantName;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak) KZTokenController *tokenController;
@end

@implementation KZDataVizualizationViewController

- (id) initWithEndPoint:(NSString *)endPoint
        applicationName:(NSString *)applicationName
             tenantName:(NSString *)tenantName
        tokenController:(KZTokenController *)tokenController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.downloadURLString = [NSString stringWithFormat:@"%@/dataviz/%@/app/download", endPoint, applicationName];
        self.applicationName = applicationName;
        self.tokenController = tokenController;
        self.tenantName = tenantName;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadBarButtonItem];
    [self configureWebView];
    [self configureActivityView];
    [self downloadZipFile];
    

}

- (void) configureWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void) configureActivityView
{
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.color = [UIColor darkGrayColor];
    [self.view addSubview:self.activityView];
    self.activityView.hidesWhenStopped = YES;
    self.activityView.center = self.webView.center;
    
    [self.activityView stopAnimating];
    self.view.userInteractionEnabled = YES;
}

- (void) downloadZipFile
{
    [self.activityView startAnimating];
    
    __weak KZDataVizualizationViewController *safeMe = self;
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"store.zip"];
    [SVHTTPRequest GET:self.downloadURLString
            parameters:nil
            saveToPath:path
              progress:^(float progress) {
                  NSLog(@"%@",[NSString stringWithFormat:@"Downloading (%.0f%%)", progress*100]);
        
              } completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                  [safeMe.activityView stopAnimating];
              }];
}

- (void) loadBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self cancelBarButtonItem];
}

-(UIBarButtonItem*) cancelBarButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                         target:self
                                                         action:@selector(cancelDataVizualization)];
}


- (void)cancelDataVizualization
{
    // TODO:
    // cancel download if any
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityView startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityView stopAnimating];
    self.view.userInteractionEnabled = YES;

    
//    NSString *payload = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    
//    if ([payload hasPrefix:SUCCESS_PAYLOAD_PREFIX]) {
//        NSString *b64 = [payload stringByReplacingOccurrencesOfString:SUCCESS_PAYLOAD_PREFIX withString:@""];
//        NSString *json = [b64 base64DecodedString];
//        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
//                                                                       options:nil
//                                                                         error:nil];
//        if (self.completion != nil) {
//            self.completion(jsonDictionary[@"access_token"], jsonDictionary[@"refresh_token"], nil);
//            [self dismissModalViewControllerAnimated:YES];
//        }
//        
//    } else if ([payload hasPrefix:ERROR_PAYLOAD_PREFIX]) {
//        
//        NSString *errorMessage = [payload stringByReplacingOccurrencesOfString:ERROR_PAYLOAD_PREFIX withString:@""];
//        NSError *error = [NSError errorWithDomain:@"KZPassiveAuthenticationError"
//                                             code:0
//                                         userInfo:@{@"Error message": errorMessage}];
//        [self handleError:error];
//        
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityView stopAnimating];
    self.view.userInteractionEnabled = YES;
    [self handleError:error];
}


- (void) handleError:(NSError *)error
{
//    if (self.completion) {
//        self.completion(nil, nil, error);
//    }
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
