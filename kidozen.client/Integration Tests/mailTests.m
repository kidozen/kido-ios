//
//  mailTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/12/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"
#import "KZMail.h"

@interface mailTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) KZMail *mailService;

@end

@implementation mailTests

- (void)setUp
{
    [super setUp];

    // Put setup code here; it will be run once, before the first test case.
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        self.application = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                              applicationKey:kzApplicationKey
                                                                   strictSSL:NO
                                                                 andCallback:^(KZResponse * r) {
                                                                     XCTAssertNotNil(r.response,@"Invalid response");
                                                                     [r.application authenticateUser:kzUser withProvider:kzProvider andPassword:kzPassword completion:^(id c) {
                                                                         NSAssert(![c  isKindOfClass:[NSError class]], @"error must be null");

                                                                         dispatch_semaphore_signal(semaphore);
                                                                     }];
                                                                 }];
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }
}

- (void)testSendEmail
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self.application sendMailTo:@"yourMail@kidozen.com"
                            from:@"yourMail@kidozen.com"
                     withSubject:@"Subject - Test email"
                     andHtmlBody:@"<i>Test HTML body</i>"
                     andTextBody:@"Text body"
                      completion:^(KZResponse *r) {
                          XCTAssertNotNil(r.response,@"Invalid response");
                          XCTAssertEqual(201, r.urlResponse.statusCode, @"Invalid status code");

                          dispatch_semaphore_signal(semaphore);
                      }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];

}


- (void)testSendEmailWithAttachments
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    UIImage *image = [self imageTestWithText:@"Kidozen Test"];
    
    [self.application sendMailTo:@"nicolas.miyasato@kidozen.com"
                            from:@"nicolas.miyasato@kidozen.com"
                     withSubject:@"Test with attachments"
                     andHtmlBody:@"<i>Test with attachments</i>"
                     andTextBody:@"Text body"
                     attachments:@{@"Kido.jpg" : UIImageJPEGRepresentation(image, 0.2)}
                      completion:^(KZResponse *r) {
                          XCTAssertNotNil(r.response,@"Invalid response");
                          XCTAssertEqual(201, r.urlResponse.statusCode, @"Invalid status code");

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
