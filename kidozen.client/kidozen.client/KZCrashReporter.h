//
//  CrashReporter.h
//  kidozen.client
//
//  Created by Christian Carnero on 3/17/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CrashReporter.h>
#import "KZBaseService.h"

/* 
 * This class will handle the crash reporting feature in the SDK.
 */
@interface KZCrashReporter : KZBaseService

- (id) initWithURLString:(NSString *)url tokenController:(KZTokenController *)tokenController;

- (void)addBreadCrumb:(NSString *)logString;

@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *build;

@property (nonatomic, assign) BOOL isInitialized ;
@property (nonatomic, weak) PLCrashReporter * baseReporter;
@property (nonatomic, copy) NSString * reporterServiceUrl;
@property (nonatomic, copy) NSString * crashReportContentAsString;
@property (nonatomic, strong) NSError * crashReporterError;
@property (nonatomic, strong) NSDictionary * crashReporterInfo;

@end
