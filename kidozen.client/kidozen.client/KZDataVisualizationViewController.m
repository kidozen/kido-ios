//
//  KZDataVisualizationViewController.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/25/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDataVisualizationViewController.h"
#import "KZTokenController.h"
#import "SVHTTPRequest.h"
#import "SSZipArchive.h"

@interface KZDataVisualizationViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *downloadURLString;

@property (nonatomic, copy) NSString *datavizName;
@property (nonatomic, copy) NSString *tenantName;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, weak) KZTokenController *tokenController;

@property (nonatomic, strong) SVHTTPClient *httpClient;

@end

@implementation KZDataVisualizationViewController

- (id) initWithEndPoint:(NSString *)endPoint
            datavizName:(NSString *)datavizName
        tokenController:(KZTokenController *)tokenController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.downloadURLString = [NSString stringWithFormat:@"https://%@/dataviz/%@/app/download", endPoint, datavizName];
        self.datavizName = datavizName;
        self.tokenController = tokenController;
        self.httpClient = [SVHTTPClient sharedClient];
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
    
    __weak KZDataVisualizationViewController *safeMe = self;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[self.datavizName stringByAppendingString:@".zip"]];

    [self.httpClient setHeaders:@{@"Authorization" : self.tokenController.kzToken}];
    [self.httpClient GET:self.downloadURLString
              parameters:nil
              saveToPath:path
                progress:^(float progress) {
                    // update progress
                    NSLog(@"%.2f", progress);
                    
    } completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error == nil) {
            [safeMe unzipFileAtPath:path folderName:safeMe.datavizName];
            [safeMe.activityView stopAnimating];
        }
    }];
}

- (void) loadBarButtonItem
{
    self.navigationItem.leftBarButtonItem = [self closeButton];
}

-(UIBarButtonItem*) closeButton
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                         target:self
                                                         action:@selector(closeDataVizualization)];
}


- (void)closeDataVizualization
{
    // Cleanup.
    [self.httpClient cancelAllRequests];
    
    [self dismissModalViewControllerAnimated:YES];
}

-(void)unzipFileAtPath:(NSString *)filePath folderName:(NSString *)folderName
{
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(main, ^ {
                           //Write To
                           NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                           NSString *documentsDirectory = [paths objectAtIndex:0]; // Get cache folder
                        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath isDirectory:NO]) {
            
            [SSZipArchive unzipFileAtPath:filePath toDestination:documentsDirectory overwrite:YES password:nil error:&error delegate:nil];
            
        } else {
            NSLog(@"File does not exist");
        }
    });
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
