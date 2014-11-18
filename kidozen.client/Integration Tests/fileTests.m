//
//  fileTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 11/18/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"
#import "KZFile.h"

@interface fileTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) KZFile *fileService;

@end

@implementation fileTests

- (void)setUp {
    [super setUp];
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        self.application = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                            applicationName:kzAppName
                                                             applicationKey:kzApplicationKey
                                                                  strictSSL:NO
                                                                andCallback:^(KZResponse * r) {
                                                                    XCTAssertNotNil(r.response,@"Invalid response");
                                                                    [r.application authenticateUser:kzUser
                                                                                       withProvider:kzProvider
                                                                                        andPassword:kzPassword
                                                                                         completion:^(id c)
                                                                    {
                                                                        NSAssert(![c  isKindOfClass:[NSError class]], @"error must be null");
                                                                        
                                                                        dispatch_semaphore_signal(semaphore);
                                                                    }];
                                                                }];
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }
}

- (void)testSendFile
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    UIImage *image = [self imageTestWithText:@"Kidozen Test"];
    
    self.fileService = [self.application fileService];
    
    
    [self.fileService uploadFileData:UIImageJPEGRepresentation(image, 0.2)
                            filePath:@"/myTests/files/ios/file.jpg"
                            callback:^(KZResponse *r) {
                                
                                XCTAssertEqual(200, r.urlResponse.statusCode, @"Invalid status code");

                                NSLog(@"Response for upload is %@", r.response);
                                
                                dispatch_semaphore_signal(semaphore);
                                
                            }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    
}

- (void)testDownloadFile
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    self.fileService = [self.application fileService];

    [self.fileService downloadFilePath:@"/myTests/files/ios/file.jpg"
                              callback:^(KZResponse *r) {
                                  XCTAssertEqual(200, r.urlResponse.statusCode, @"Invalid status code");

                                  NSLog(@"Response for download is %@", r.response);
                                  dispatch_semaphore_signal(semaphore);

        
                              }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    
}

- (void)testBrowseDirectory
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    self.fileService = [self.application fileService];
    
    [self.fileService browseAtPath:@"/" callback:^(KZResponse *r) {
        
        XCTAssertEqual(200, r.urlResponse.statusCode, @"Invalid status code");
        
        NSLog(@"Response for browse is %@", r.response);
        
        dispatch_semaphore_signal(semaphore);
        
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    
}

- (UIImage *)imageTestWithText:(NSString *)string
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]};
    
    CGSize sz = [string sizeWithAttributes:attributes];
    sz.width += 100;
    CGRect rect = CGRectZero;
    rect.size = sz;
    
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = string;
    
    
    UIGraphicsBeginImageContext(label.bounds.size);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGImageRef viewImage = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
    return [UIImage imageWithCGImage:viewImage];
}

@end

@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end
