//
//  datasourcetests.m
//  kidozen.client
//
//  Created by Christian Carnero on 2/28/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"
#import "KZDatasource.h"
#import "KZPubSubChannel.h"

@interface datasourceTests : XCTestCase
@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) NSDictionary * nestedDataDict;
@property (nonatomic, strong) NSDictionary * dataDict;

@property (nonatomic, strong) KZPubSubChannel *subscribeChannel;
@end

@implementation datasourceTests

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
        
        self.application = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                              applicationKey:kzApplicationKey
                                                                   strictSSL:NO
                                                                 andCallback:^(KZResponse * r) {
                                                                     XCTAssertNotNil(r.response, @"Invalid response");
                                                                     XCTAssertNil(r.error, @"Should not have an error");
                                                                     
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

- (void)testQueryAllLog
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.application.log all:^(KZResponse *r) {
        XCTAssertEqual(200,r.urlResponse.statusCode, @"Invalid status code");
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
        XCTAssertEqualObjects([[r.response objectForKey:@"error"] objectForKey:@"code"], @"ETIMEDOUT", @"Must timeout"); ;
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
        XCTAssertEqualObjects([[r.response objectForKey:@"error"] objectForKey:@"code"], @"ETIMEDOUT", @"Must timeout"); ;
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}


- (void)testShouldExecuteGetWithDataAsDictionary
{
    KZDatasource *ds = [self.application DataSourceWithName:@"test-query-params"];

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [ds QueryWithData:self.dataDict completion:^(KZResponse *r) {
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


- (void) testPubSub
{
    self.subscribeChannel = [self.application PubSubChannelWithName:@"MyChannel"];

    [self.subscribeChannel subscribe:^(id message) {
        NSLog(@"message is %@", message);
    }];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        KZPubSubChannel *publishChannel = [self.application PubSubChannelWithName:@"MyChannel"];
        id message = @{@"message": @"channel"};
        
        [publishChannel publish:message completion:^(KZResponse * k) {
            NSLog(@"Response publish %@", k.response);
        }];
        
        
    });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    

}
@end
