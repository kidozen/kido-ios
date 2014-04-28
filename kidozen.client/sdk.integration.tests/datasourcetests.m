//
//  datasourcetests.m
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"

@interface datasourcetests : XCTestCase
@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) NSDictionary * nestedDataDict;
@property (nonatomic, strong) NSDictionary * dataDict;
@end

@implementation datasourcetests

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

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testShouldExecuteLog
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.application writeLog:@{@"message": @"text"} withLevel:LogLevelVerbose completion:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldExecuteGet
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds Query:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}
- (void)testShouldExecuteGetWithTimeout
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query-delayed"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithTimeout:1 callback:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        XCTAssertEqual(408,r.urlResponse.statusCode, @"Must be a timeout response");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldExecuteInvoke
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-operation"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [ds Invoke:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldExecuteInvokeWithTimeout
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-operation-delayed"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [ds InvokeWithTimeout:1 callback:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        XCTAssertEqual(408,r.urlResponse.statusCode, @"Must be a timeout response");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}


- (void)testShouldExecuteGetWithDataAsDictionary
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query-params"];

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithData:_dataDict completion:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldExecuteGetWithDataAsNestedDictionary
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query-params"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithData:_nestedDataDict completion:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

- (void)testShouldExecuteInvokeWithDataAsDictionary
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-operation-params"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds InvokeWithData:_dataDict completion:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}
- (void)testShouldReturnError
{
    KZDatasource *ds = [self.application DataSourceWithName:@"invalid"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [ds Query:^(KZResponse *r) {
        XCTAssertEqual(404,r.urlResponse.statusCode);
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

@end
