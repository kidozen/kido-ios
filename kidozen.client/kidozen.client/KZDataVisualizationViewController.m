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
#import "KZApplicationAuthentication.h"
#import "KZUser.h"
#import "KZApplicationConfiguration.h"

#define kDownloadURLTemplate @"https://%@.%@/api/v2/visualizations/%@/app/download?type=mobile"

@interface KZDataVisualizationViewController () <UIWebViewDelegate>

@property (nonatomic, copy) NSString *downloadURLString;

@property (nonatomic, copy) NSString *datavizName;
@property (nonatomic, copy) NSString *tenantName;
@property (nonatomic, copy) NSString *appName;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *bytesWritten;

@property (nonatomic, weak) KZTokenController *tokenController;

@property (nonatomic, strong) SVHTTPClient *httpClient;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *provider;

@end

@implementation KZDataVisualizationViewController

- (instancetype) initWithApplicationConfig:(KZApplicationConfiguration *)appConfig
                                   appAuth:(KZApplicationAuthentication *)appAuth
                                    tenant:(NSString *)tenant
                                 strictSSL:(BOOL)strictSSL
                               dataVizName:(NSString *)datavizName;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.downloadURLString = [NSString stringWithFormat:kDownloadURLTemplate, appConfig.name, appConfig.domain, datavizName];
        
        self.datavizName = datavizName;
        self.appName = appConfig.name;
        
        self.username = appAuth.kzUser.user;
        self.password = appAuth.kzUser.pass;
        self.provider = appAuth.kzUser.provider;
        
        self.tenantName = tenant;
        
        self.tokenController = appAuth.tokenController;
        self.httpClient = [SVHTTPClient sharedClient];
        [self initializeHttpClientWithStrictSSL:strictSSL];
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.bytesWritten = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];

    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.datavizName;
    
    [self loadBarButtonItem];
    [self configureWebView];
    [self configureActivityView];
    [self configureProgressView];
    [self configureBytesWritten];
    [self downloadZipFile];

}

-(void) initializeHttpClientWithStrictSSL:(BOOL)strictSSL
{
    if (!self.httpClient) {
        self.httpClient = [[SVHTTPClient alloc] init];
    }
    
    [self.httpClient setDismissNSURLAuthenticationMethodServerTrust:!strictSSL];
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

- (void)configureBytesWritten
{
    [self.view addSubview:self.bytesWritten];
    self.bytesWritten.center = self.view.center;
    self.bytesWritten.font = [UIFont fontWithName:@"Helvetica" size:14];
    self.bytesWritten.textColor = [UIColor grayColor];
    self.bytesWritten.textAlignment = NSTextAlignmentCenter;
    
    CGRect fr = self.bytesWritten.frame;
    int offset = 5;
    fr.origin.y = self.activityView.frame.origin.y + self.activityView.frame.size.height + offset;
    self.bytesWritten.frame = fr;
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

    NSString *path = [[self tempDirectory] stringByAppendingPathComponent:[self.datavizName stringByAppendingString:@".zip"]];
    self.progressView.hidden = YES;
    [self.activityView startAnimating];
    
    [self.httpClient setHeaders:@{@"Authorization" : self.tokenController.kzToken}];
    [self.httpClient GET:self.downloadURLString
              parameters:nil
              saveToPath:path
                progress:^(float progress) {
                    NSFileManager *man = [NSFileManager defaultManager];
                    NSDictionary *attrs = [man attributesOfItemAtPath: path error: NULL];
                    
                    // Only show the progressView if progress > 0
                    if (progress < 0) {
                        if (safeMe.activityView.isAnimating == NO) {
                            [safeMe.activityView startAnimating];
                        }
                        if (safeMe.bytesWritten.superview == nil) {
                            [safeMe configureBytesWritten];
                        }
                        
                        safeMe.bytesWritten.text = [NSString stringWithFormat:@"%.0f kBytes", [attrs fileSize] / 1024.0];
                        
                        
                    } else {
                        if (safeMe.activityView.isAnimating == YES) {
                            [safeMe.activityView stopAnimating  ];
                        }
                        safeMe.bytesWritten.hidden = YES;
                        safeMe.progressView.hidden = NO;

                        [safeMe.progressView setProgress:progress animated:YES];
                    }
                    
    } completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error == nil) {
            [safeMe unzipFileAtPath:path folderName:[self dataVizDirectory]];
            [safeMe.progressView removeFromSuperview];
            [safeMe.bytesWritten removeFromSuperview];
        } else {
            [safeMe handleError:error];
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
                [safeMe replacePlaceHolders];
                [safeMe loadWebView];
            } else {
                [safeMe handleError:error];
            }
            
        } else {
            [safeMe.activityView stopAnimating];
            [safeMe handleError:nil];
        }
    });
}

- (void)replacePlaceHolders
{
    NSURL *url = [self indexFileURL];
    NSError *error;
    NSString *indexString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        [self handleError:error];
    }

    NSString *options = [self stringOptionsForTokenRefresh];
    NSString *marketplace = [NSString stringWithFormat:@"\"%@\"", self.tenantName];
    NSString *appName = [NSString stringWithFormat:@"\"%@\"", self.appName];
    
    indexString = [indexString stringByReplacingOccurrencesOfString:@"{{:options}}" withString:options];
    indexString = [indexString stringByReplacingOccurrencesOfString:@"{{:marketplace}}"  withString:marketplace];
    indexString = [indexString stringByReplacingOccurrencesOfString:@"{{:name}}" withString:appName];
    
    NSError *writeError;
    [indexString writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
    if (writeError != nil) {
        [self handleError:writeError];
    }
}


- (NSString *) stringOptionsForTokenRefresh {
    NSData *jsonData;
    if (self.username != nil && self.password != nil && self.provider != nil ) {
        
        jsonData = [NSJSONSerialization dataWithJSONObject:@{ @"token" : self.tokenController.authenticationResponse,
                                                           @"username" : self.username,
                                                           @"password" : self.password,
                                                           @"provider" : self.provider
                                                          }
                                               options:0
                                                 error:nil];
        
        
    } else {
        jsonData = [NSJSONSerialization dataWithJSONObject:@{ @"token" : self.tokenController.authenticationResponse}
                                               options:0
                                                 error:nil];
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)loadWebView {
    NSURL *url = [self indexFileURL];
    
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
    if (self.successCb) {
        self.successCb();
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityView stopAnimating];
    self.view.userInteractionEnabled = YES;
    [self handleError:error];
}

- (void) handleError:(NSError *)error
{
    NSString *message;
    if (error != nil) {
        message = [NSString stringWithFormat:@"Error while loading visualization. Please try again later. Error is %@", error];
    } else {
        message = @"Please try again later";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Could not load visualization"
                                message:message
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil] show];

    if (self.errorCb) {
        self.errorCb(error);
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)tempDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)dataVizDirectory
{
    return [[self tempDirectory] stringByAppendingPathComponent:self.datavizName];
}

- (NSString *) dataVizFileName
{
    return [[self tempDirectory] stringByAppendingPathComponent:[self.datavizName stringByAppendingString:@".zip"]];
}

- (NSURL *) indexFileURL
{
    NSString *indexFile = [[self dataVizDirectory] stringByAppendingPathComponent:@"index.html"];
    return [NSURL fileURLWithPath:indexFile];
}

@end
