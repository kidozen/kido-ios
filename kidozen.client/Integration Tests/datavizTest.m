//
//  datavizTest.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 11/21/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KZApplication.h"
#import "Constants.h"

@interface datavizTest : XCTestCase

@property (nonatomic, strong) KZApplication * application;

@end

@implementation datavizTest

- (void)setUp {
    [super setUp];
    if (!self.application) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        self.application = [[KZApplication alloc] initWithTenantMarketPlace:kzAppCenterUrl
                                                            applicationName:kzAppName
                                                             applicationKey:kzApplicationKey
                                                                  strictSSL:NO
                                                                andCallback:^(KZResponse * r) {
                                                                    XCTAssertNotNil(r.response,@"Invalid response");
                                                                    [r.application authenticateUser:kzUser
                                                                                       withProvider:kzProvider
                                                                                        andPassword:kzPassword
                                                                                         completion:^(id c)
                                                                     {
                                                                         NSAssert(![c  isKindOfClass:[NSError class]], @"error must be null");
                                                                         
                                                                         dispatch_semaphore_signal(semaphore);
                                                                     }];
                                                                }];
        
        assert(self.application);
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];
    }

}

- (void)testDownloadDataViz {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    // Clustered.
    [self.application showDataVisualizationWithName:@"clustered" success:^{
        // Success code.
        XCTAssert(YES, @"Pass");
        dispatch_semaphore_signal(semaphore);


    } error:^(NSError *error) {
        XCTAssert(NO, @"Pass");
        
    }];

    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100]];


}

@end
