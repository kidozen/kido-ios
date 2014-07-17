//
//  CrashReporter.m
//  kidozen.client
//
//  Created by Christian Carnero on 3/17/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZCrashReporter.h"

// Importing/Redeclaring methods.
@interface KZBaseService ()
@property (nonatomic, strong) SVHTTPClient *client;
@end



@interface KZCrashReporter()

@property (nonatomic, copy, readwrite) NSString *version;
@property (nonatomic, copy, readwrite) NSString *build;

@end

@implementation KZCrashReporter

NSMutableDictionary * internalCrashReporterInfo;

static int breadCrumbsFd;

/* A custom post-crash callback */
void post_crash_callback (siginfo_t *info, ucontext_t *uap, void *context) {
    close(breadCrumbsFd);
}


- (id) initWithURLString:(NSString *)url tokenController:(KZTokenController *)tokenController
{
    self = [super init];
    
    if (self) {
        
        self.tokenController = tokenController;
        
        internalCrashReporterInfo = [[NSMutableDictionary alloc] init];
        self.client = [[SVHTTPClient alloc] init];
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
    self.reporterServiceUrl = url;
}

-(void) enableCrashReporter {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    self.baseReporter = crashReporter;
    
    if ([crashReporter hasPendingCrashReport]) {
        [self manageCrashReport];
    }
    
    
    /* Set up post-crash callbacks */
    PLCrashReporterCallbacks cb = {
        .version = 0,
        .context = nil,
        .handleSignal = post_crash_callback
    };
    
    [self.baseReporter setCrashCallbacks: &cb];
    
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
            self.crashReporterError = error;
        }
        else {
            self.crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Could not load crash report" forKey:@"description"]];
        }
    }
    else {
        self.crashReportContentAsString = [self getReportAsString:crashData withError:error];
        if (error) {
            self.crashReporterError = error;
        }
        else {
            [internalCrashReporterInfo setObject:self.crashReportContentAsString forKey:@"ReporterDataAsString"];
            if (self.reporterServiceUrl) {
                [self postReport:self.crashReportContentAsString];
            }
            else {
                [self saveReportToFile:self.crashReportContentAsString];
            }
        }
    }

    return;
}

- (void) postReport:(NSString *) reportdataasstring
{
    
    self.version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    self.version = self.version && self.version.length > 0 ? self.version : @"0";
    self.build = self.build && self.build.length > 0 ? self.build : @"not set";
    
    NSString *breadcrumbs = [NSString stringWithContentsOfFile:[self breadcrumbFilename] encoding:NSUTF8StringEncoding error:NULL];
    
    if (breadcrumbs == nil) {
        breadcrumbs = @"";
    };
    
    NSArray *breadcrumbsArray = [breadcrumbs componentsSeparatedByString:@"\n"];
    
    NSDictionary *jsonDictionary = @{@"REPORT": self.crashReportContentAsString,
                                     @"VERSION" : self.version,
                                     @"BUILD" : self.build,
                                     @"BREADCRUMBS" : breadcrumbsArray};
    
    [self.client setBasePath:self.reporterServiceUrl];
    [self.client setSendParametersAsJSON:YES];
    [self.client setDismissNSURLAuthenticationMethodServerTrust:YES];
    [self addAuthorizationHeader];
    
    __weak KZCrashReporter *safeMe = self;
    
    [self.client POST:@"" parameters:jsonDictionary completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {

        if (!error) {
            NSError *purgeError;
            if (![safeMe.baseReporter purgePendingCrashReportAndReturnError:&purgeError]) {
                NSLog(@"Something happened while removing dump. Error is %@", purgeError);
            };

            [safeMe removeBreadcrumbsFile];
        }
        
        safeMe.crashReporterError = error;
        if (response) {
            [internalCrashReporterInfo setObject:response forKey:@"ServiceResponse"];
        }
        if (urlResponse) {
            [internalCrashReporterInfo setObject:urlResponse forKey:@"UrlRepsonse"];
        }
    }];
}

- (void) removeBreadcrumbsFile
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self breadcrumbFilename]]) {
        NSError *removeError;
        [[NSFileManager defaultManager] removeItemAtPath:[self breadcrumbFilename] error:&removeError];
        if (removeError != nil) {
            NSLog(@"Could note remove %@. Error is %@", [self breadcrumbFilename], removeError);
        }
    }
}

- (void) saveReportToFile:(NSString *) reportdataasstring {

    NSString *outputPath = [self pathForFilename:@"KidozenCrashReport.crash"];
 
    if (![reportdataasstring writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
        self.crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Failed to write crash report" forKey:@"description"]];
        NSLog(@"Failed to write crash report");
    } else {
        [internalCrashReporterInfo setObject:[NSString stringWithFormat:@"Saved crash report to: %@", outputPath] forKey:@"CrashOutputPath"];
        NSLog(@"Saved crash report to: %@", outputPath);
    }
finish:
    [self.baseReporter purgePendingCrashReport];
    return;
}

- (NSString *) getReportAsString :(NSData *) crashData withError:(NSError *) error {
    PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
    if (report == nil) {
        self.crashReporterError = [NSError errorWithDomain:@"CrashReporter" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Could not parse crash report" forKey:@"description"]];
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
    // Cap to N kBytes.
    if (!breadCrumbsFd) {
        breadCrumbsFd = open([[self breadcrumbFilename] UTF8String], O_CREAT | O_WRONLY, 0644);
    }
    
    // get the size of the file
    
    const char *logStr = [logString UTF8String];
    write(breadCrumbsFd, logStr,  strlen(logStr));

}

- (NSString *)breadcrumbFilename
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

