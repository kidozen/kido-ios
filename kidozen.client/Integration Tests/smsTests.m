//
//  smsTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/16/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "KZMail.h"

#import "Constants.h"

@interface smsTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) KZMail *mailService;

@end

@implementation smsTests

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
                                                                        XCTAssertNotNil(c,@"User not authenticated");
                                                                        dispatch_semaphore_signal(semaphore);
                                                                    }];
                                                                }];
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }

}

- (void) testSendSMS
{
    KZSMSSender *smsSender = [self.application SMSSenderWithNumber:@"1569691823"];
    [smsSender send:@"Hola test" completion:^(KZResponse *r) {
        NSLog(@"Response is %@", r.response);
    }];
}

@end
