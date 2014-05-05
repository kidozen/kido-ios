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

@end

@implementation loggingTests

- (void)setUp
{
    [super setUp];
    
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

        self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                             applicationName:kzAppName
                                                              applicationKey:kApplicationKey
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

- (void)testShouldOverrideApplicationKeyWithUsernameAndPassword
{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.application = [[KZApplication alloc] initWithTennantMarketPlace:kzAppCenterUrl
                                                         applicationName:kzAppName
                                                               strictSSL:NO
                                                             andCallback:^(KZResponse * r) {
                                                                 XCTAssertNotNil(r.response,@"Invalid response");
                                                                 [r.application authenticateUser:kzUser
                                                                                    withProvider:kzProvider
                                                                                     andPassword:kzPassword
                                                                                      completion:^(id c) {
                                                                                          XCTAssertNotNil(c,@"User not authenticated");
                                                                                          dispatch_semaphore_signal(semaphore);
                                                                 }];
                                                             }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    
    
    // If user authenticated with username and password, one way to test whether it successfully
    // overrode the applicationKey token, is to try to call a datasource which only has permissions
    // to run using username and password.
    [self executeDataSource];
    
}

- (void) executeDataSource
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

-(void) testShouldTimeOutAndRecoverKey
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    self.application.authCompletionBlock = ^(id response) {
        NSLog(@"%@", response);
        dispatch_semaphore_signal(semaphore);

    };
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}

@end
