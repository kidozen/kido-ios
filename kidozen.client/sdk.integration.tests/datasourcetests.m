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
@property (nonatomic, retain) KZApplication * application;
@end

@implementation datasourcetests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                                applicationName:kzAppName
                                                            bypassSSLValidation:YES
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
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testShouldExecuteGetWithDataAsDictionary
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query-params"];
    NSDictionary * data = [NSDictionary dictionaryWithObject:@"?k=kidozen" forKey:@"path"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithData:data completion:^(KZResponse *r) {
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
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:@"path",@"/",[NSDictionary dictionaryWithObject:@"kidozen" forKey:@"k"],@"qs",nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithData:data completion:^(KZResponse *r) {
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
    NSDictionary * data = [NSDictionary dictionaryWithObject:@"?k=kidozen" forKey:@"path"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds InvokeWithData:data completion:^(KZResponse *r) {
        XCTAssertNotNil(r,@"invalid response");
        NSNumber* status =  [[r.response objectForKey:@"data"] objectForKey:@"status"] ;
        XCTAssertEqual(200,[status intValue], @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}
- (void)testShouldReturnError
{
    KZDatasource *ds = [self.application DataSourceWithName:@"invalid"];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [ds Query:^(KZResponse *r) {
        XCTAssertNotNil(r.error,@"invalid response");
        XCTAssertEqual(1,[r.error code]);
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
