//
//  configurationTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/17/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "KZApplication.h"
#import "KZConfiguration.h"
#import "Constants.h"


@interface configurationTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;

@end

@implementation configurationTests

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
                                                                    XCTAssertNil(r.error, @"Must not have an error");
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

- (void)testSaveConfig
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    KZConfiguration *config = [self.application ConfigurationWithName:@"TestConfig"];
    
    [config save:@{@"keyTest" : @"value"} completion:^(KZResponse *r) {
        
        NSLog(@"--- Response is %@", r.response);
        dispatch_semaphore_signal(semaphore);

    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];

    
}

@end
