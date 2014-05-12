//
//  applicationtests.m
//  kidozen.client
//
//  Created by Christian Carnero on 3/7/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"

@interface applicationTests : XCTestCase
@property (nonatomic, retain) KZApplication * application;
@end

@implementation applicationTests

- (void)setUp
{
    [super setUp];
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                         strictSSL:NO
                                                                 andCallback:^(KZResponse * r) {
                                                                     XCTAssertNotNil(r.response,@"Invalid response");
                                                                     dispatch_semaphore_signal(semaphore);
                                                                 }];
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShouldAuthenticate
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.application authenticateUser:kzUser withProvider:kzProvider andPassword:kzPassword completion:^(id c) {
        XCTAssertNotNil(c,@"User not authenticated");
        dispatch_semaphore_signal(semaphore);
    }];
    assert(self.application);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldFailAuthentication
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.application authenticateUser:@"none@kido.com" withProvider:kzProvider andPassword:kzPassword completion:^(id c) {
        XCTAssertNotNil(c,@"User not authenticated");
        dispatch_semaphore_signal(semaphore);
    }];
    assert(self.application);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}
@end
