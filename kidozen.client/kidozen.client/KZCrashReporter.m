//
//  CrashReporter.m
//  kidozen.client
//
//  Created by Christian Carnero on 3/17/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZCrashReporter.h"

@interface KZCrashReporter()

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSFileHandle *logFileHandler;

@end

@implementation KZCrashReporter

@synthesize reporterServiceUrl = _reporterServiceUrl;

NSMutableDictionary * internalCrashReporterInfo;

- (id) initWithURLString:(NSString *)url withToken:(NSString *)token
{
    self = [super init];
    
    if (self) {
        self.token = token;
        internalCrashReporterInfo = [[NSMutableDictionary alloc] init];
        _client = [[SVHTTPClient alloc] init];
        [self enableCrashReporterWithUrl:url];
    }
    return self;
}

- (void) setReporterServiceUrl:(NSString *)aURL
{
    NSMutableString * url = [ NSMutableString stringWithString:aURL];
    if ([aURL indexOf:@"/"] == [aURL length] ) {
        [url appendString:@"/"];
    }
    [url appendString: @"api/v3/logging/crash/ios/dump"];
    _reporterServiceUrl = url;
}

-(NSString *) reporterServiceUrl
{
    return _reporterServiceUrl;
}

-(void) enableCrashReporter {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    if ([crashReporter hasPendingCrashReport]) {
        [self manageCrashReport];
    }
    
    if (![crashReporter enableCrashReporterAndReturnError:&error]) {
        NSLog(@"coult not enable crash reporter : %@", error);
    }

    self.isInitialized = YES;
}

-(void) enableCrashReporterWithUrl:(NSString *) url
{
    [self setReporterServiceUrl: url];
    [self enableCrashReporter];
}

- (void) manageCrashReport {
    NSError * error;
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];

    NSData * crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData == nil) {
        NSLog(@"Could not load crash report: %@", error);
        if (error) {
            _crashReporterError = error;
        }
        else {
            _crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Could not load crash report" forKey:@"description"]];
        }
    }
    else {
        _crashReportContentAsString = [self getReportAsString:crashData withError:error];
        if (error) {
            _crashReporterError = error;
        }
        else {
            [internalCrashReporterInfo setObject:_crashReportContentAsString forKey:@"ReporterDataAsString"];
            if (_reporterServiceUrl) {
                [self postReport:_crashReportContentAsString];
            }
            else {
                [self saveReportToFile:_crashReportContentAsString];
            }
        }
    }

    return;
}

- (void) postReport:(NSString *) reportdataasstring
{
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:kCFBundleVersionKey];
    NSString *breadcrumbs = [NSString stringWithContentsOfFile:[self logFilename] encoding:NSUTF8StringEncoding error:NULL];

    NSDictionary *jsonDictionary = @{@"report": _crashReportContentAsString,
                                     @"version" : versionString,
                                     @"build" : build,
                                     @"breadcrumbs" : breadcrumbs};
    
    [_client setBasePath:_reporterServiceUrl];
    [_client setSendParametersAsJSON:YES];
    [_client setDismissNSURLAuthenticationMethodServerTrust:YES];
    [self addAuthorizationHeader];
//    NSLog(@"------ %@", jsonDictionary);
    
//    [_client POST:@"" parameters:jsonDictionary completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
//        if (!error) {
//                [_baseReporter purgePendingCrashReport];
//        }
//        _crashReporterError = error;
//        if (response) {
//            [internalCrashReporterInfo setObject:response forKey:@"ServiceResponse"];
//        }
//        if (urlResponse) {
//            [internalCrashReporterInfo setObject:urlResponse forKey:@"UrlRepsonse"];
//        }
//    }];
}

- (void) saveReportToFile:(NSString *) reportdataasstring {

    NSString *outputPath = [self pathForFilename:@"KidozenCrashReport.crash"];
 
    if (![reportdataasstring writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        _crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Failed to write crash report" forKey:@"description"]];
        NSLog(@"Failed to write crash report");
    } else {
        [internalCrashReporterInfo setObject:[NSString stringWithFormat:@"Saved crash report to: %@", outputPath] forKey:@"CrashOutputPath"];
        NSLog(@"Saved crash report to: %@", outputPath);
    }
finish:
    [_baseReporter purgePendingCrashReport];
    return;
}

- (NSString *) getReportAsString :(NSData *) crashData withError:(NSError *) error {
    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
    if (report == nil) {
        _crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Could not parse crash report" forKey:@"description"]];
        return Nil;
    }
    NSLog(@"Crashed on %@", report.systemInfo.timestamp);
    NSLog(@"Crashed with signal %@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name, report.signalInfo.code, report.signalInfo.address);
    [internalCrashReporterInfo setObject:report.systemInfo.timestamp forKey:@"CrashedOn"];
    [internalCrashReporterInfo setObject:[NSString stringWithFormat:@"%@ (code %@, address=0x%" PRIx64 ")", report.signalInfo.name, report.signalInfo.code, report.signalInfo.address] forKey:@"CrashedWithSignal"];
    return [PLCrashReportTextFormatter stringValueForCrashReport: report withTextFormat:PLCrashReportTextFormatiOS];
}

- (void)addBreadCrumb:(NSString *)logString
{
    // TODO
    // Cap to 512 bytes.
    if(!self.logFileHandler) {
        [[NSFileManager defaultManager] createFileAtPath:[self logFilename] contents:nil attributes:nil];
        self.logFileHandler = [NSFileHandle fileHandleForWritingAtPath:[self logFilename]];        
    }
    
    [self.logFileHandler writeData:[logString dataUsingEncoding:NSUTF8StringEncoding]];
    [self.logFileHandler synchronizeFile];
    
}

- (NSString *)logFilename
{
    return [self pathForFilename:@"CrashUserLogs.log"];
}

- (NSString *)pathForFilename:(NSString *)filename
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:filename];
    
}
@end

