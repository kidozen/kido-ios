//
//  sdk_integration_tests.m
//  sdk.integration.tests
//
//  Created by Christian Carnero on 11/11/13.
//  Copyright (c) 2013 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"

@interface sdk_integration_tests : XCTestCase

@end

@implementation sdk_integration_tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    KZApplication * app = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                            applicationName:kzAppName
                                                        bypassSSLValidation:YES
                                                                andCallback:^(KZResponse * r) {
        XCTAssertNotNil(r.response,@"Invalid response");
        [r.application authenticateUser:kzUser withProvider:kzProvider andPassword:kzPassword completion:^(id c) {
            XCTAssertNotNil(c,@"User not created");
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    assert(app);
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

}

@end
