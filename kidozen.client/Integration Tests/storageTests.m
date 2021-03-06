//
//  storageTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/8/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"
#import "KZStorage.h"

@interface storageTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;

@end

@implementation storageTests

- (void)setUp
{
    [super setUp];

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

- (void)testStorageWithDotsInKeys
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    KZStorage *storage = [self.application StorageWithName:@"test-storage"];
    
    [storage createPrivate:@{@"key.1": @"value"} completion:^(KZResponse *r) {
        XCTAssertEqual(201,r.urlResponse.statusCode, @"Invalid status code");
        dispatch_semaphore_signal(semaphore);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    
}

- (void)testQuery
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    KZStorage *storage = [self.application StorageWithName:@"test-query"];

    NSString * queryString = @"{}";
    [storage query:queryString withBlock:^(KZResponse * r) {
        XCTAssertEqual(200,r.urlResponse.statusCode, @"Invalid status code");

        dispatch_semaphore_signal(semaphore);

    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];


}
@end
