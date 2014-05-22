//
//  mailTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/12/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
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
        
        self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                              applicationKey:nil
                                                                   strictSSL:NO
                                                                 andCallback:^(KZResponse * r) {
                                                                     XCTAssertNotNil(r.response,@"Invalid response");
                                                                     [r.application authenticateUser:kzUser withProvider:kzProvider andPassword:kzPassword completion:^(id c) {
                                                                         XCTAssertNotNil(c,@"User not authenticated");
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

    [self.application sendMailTo:@"nicolas.miyasato@kidozen.com"
                            from:@"nicolas.miyasato@kidozen.com"
                     withSubject:@"testSubject"
                     andHtmlBody:@"htmlBody here"
                     andTextBody:@"hola"
                      completion:^(KZResponse *r) {
                          NSLog(@"response is %@", r.urlResponse);
                          dispatch_semaphore_signal(semaphore);
                      }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];

}


@end
