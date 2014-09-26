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
@property (nonatomic, strong) UIProgressView *progressView;

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
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadBarButtonItem];
    [self configureWebView];
    [self configureActivityView];
    [self configureProgressView];
    [self downloadZipFile];
    

}

- (void) configureWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void)configureProgressView
{
    [self.view addSubview:self.progressView];
    self.progressView.center = self.view.center;
    
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
    __weak KZDataVisualizationViewController *safeMe = self;

    NSString *path = [[self tempDictionary] stringByAppendingPathComponent:[self.datavizName stringByAppendingString:@".zip"]];

    [self.httpClient setHeaders:@{@"Authorization" : self.tokenController.kzToken}];
    [self.httpClient GET:@"http://168.192.1.140:8000/dataviz-stockinfoviz.zip" // TODO: self.downloadURLString
              parameters:nil
              saveToPath:path
                progress:^(float progress) {
                    [safeMe.progressView setProgress:progress animated:YES];
                    
    } completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (error == nil) {
            [safeMe unzipFileAtPath:path folderName:[self dataVizDirectory]];
            [safeMe.progressView removeFromSuperview];
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
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[self dataVizDirectory] error:nil];
    [fm removeItemAtPath:[self dataVizFileName] error:nil];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)tempDictionary
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)dataVizDirectory
{
    return [[self tempDictionary] stringByAppendingPathComponent:self.datavizName];
}

- (NSString *) dataVizFileName
{
    return [[self dataVizDirectory] stringByAppendingPathComponent:[self.datavizName stringByAppendingString:@".zip"]];
}

-(void)unzipFileAtPath:(NSString *)filePath folderName:(NSString *)folderName
{
    
    __weak KZDataVisualizationViewController *safeMe = self;
    [self.activityView startAnimating];

    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_async(main, ^ {
        
        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:filePath isDirectory:NO]) {
            
            if ([SSZipArchive unzipFileAtPath:filePath
                                toDestination:folderName
                                    overwrite:YES
                                     password:nil
                                        error:&error
                                     delegate:nil] == YES)
            {
                
                [safeMe loadWebViewUsingDirectory:folderName];
                // load  documentsDirectory in webView.

            }
            
        } else {
            [safeMe.activityView stopAnimating];

            NSLog(@"File does not exist");
        }
    });
}



- (void)loadWebViewUsingDirectory:(NSString *)directoryPath {
    NSString *indexFile = [directoryPath stringByAppendingPathComponent:@"index.html"];
    NSURL *url = [NSURL fileURLWithPath:indexFile];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
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
    
    NSLog(@"Error is %@", error);
    
    [self dismissModalViewControllerAnimated:YES];
}

@end
