//
//  loggingTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/5/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Constants.h"
#import "KZApplication.h"

static NSString *const kApplicationKey = @"TG2wIc9xnCsZmcYaiC/+g1FpAP96X+G0ZKXjCzH/viM=";

@interface loggingTests : XCTestCase

@property (nonatomic, strong) KZApplication *application;
@property (nonatomic, strong) NSDictionary *nestedDataDict;
@property (nonatomic, strong) NSDictionary *dataDict;

@end

@implementation loggingTests

- (void)setUp
{
    [super setUp];
    self.nestedDataDict = @{@"path": @"/",
                            @"qa" : @{@"k": @"kidozen"}
                            };
    
    self.dataDict = @{@"path": @"?k=kidozen"};
    // Put setup code here; it will be run once, before the first test case.
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                              applicationKey:kApplicationKey
                                                                   strictSSL:NO
                                                                 andCallback:^(KZResponse * r) {
                                                                     XCTAssertNotNil(r.response,@"Invalid response");
                                                                     NSLog(@"%@", r);
                                                                     dispatch_semaphore_signal(semaphore);
                                                                 }];
        
        
        
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testShouldExecuteLog
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.application writeLog:@{@"key" : @"value"}
                     withLevel:LogLevelVerbose completion:^(KZResponse *r) {
                         
                         XCTAssertNotNil(r,@"invalid response");
                         XCTAssertEqual(201, r.urlResponse.statusCode, @"Invalid status code");
                         dispatch_semaphore_signal(semaphore);
                         
                     }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}


@end
