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

@interface KZCrashReporter : KZBaseService

- (id) initWithURLString:(NSString *)url withToken:(NSString *)token;

- (void)addBreadCrumb:(NSString *)logString;

@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *build;

@property (atomic) BOOL isInitialized ;
@property (atomic, strong) PLCrashReporter * baseReporter;
@property (atomic, strong) NSString * reporterServiceUrl;
@property (atomic, strong) NSString * crashReportContentAsString;
@property (atomic, strong) NSError * crashReporterError;
@property (atomic, strong) NSDictionary * crashReporterInfo;

@end
