//
//  serviceTests.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/16/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"

@interface serviceTests : XCTestCase

@property (nonatomic, strong) KZApplication * application;
@property (nonatomic, strong) NSDictionary * nestedDataDict;
@property (nonatomic, strong) NSDictionary * dataDict;

@end

@implementation serviceTests

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
                                                                        XCTAssertNotNil(c,@"User not authenticated");
                                                                        dispatch_semaphore_signal(semaphore);
                                                                    }];
                                                                }];
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }
}

- (void) testServiceWithNoData
{
    NSString *jsonString = @"{}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *myDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    id myService = [self.application LOBServiceWithName:@"Google"];
    [myService invokeMethod:@"" withData:myDictionary completion:^(KZResponse * k) {
        dispatch_semaphore_signal(semaphore);
    }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
}
@end
