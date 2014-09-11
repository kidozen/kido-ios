//
//  KZAnalytics.m

#import "KZAnalytics.h"
#import "KZApplication.h"
#import "KZDeviceInfo.h"

@interface KZAnalytics ()

@property (nonatomic, weak) KZLogging *logging;
@property (nonatomic, strong) KZDeviceInfo *deviceInfo;

@end

@implementation KZAnalytics

- (instancetype)initWithLoggingService:(KZLogging *)logging
{
    self = [super init];
    if (self) {
        self.logging = logging;
        self.deviceInfo = [[KZDeviceInfo alloc] init];
    }
    return self;
}

- (void)tagClick:(NSString *)buttonName
{
    [self tagEvent:@"Clicked" value:buttonName];
}

- (void)tagView:(NSString *)viewName
{
    [self tagEvent:@"Views" value:viewName];
}

- (void)tagSession
{
    [self tagEvent:@"user-session" attributes:self.deviceInfo.properties];
}

- (void) tagEvent:(NSString *)customEventName attributes:(NSDictionary *)attributes
{
    NSDictionary *params;
    
    if (attributes != nil) {
        params = @{@"eventName" : customEventName,
                   @"eventAttr" : attributes};
    } else {
        params = @{@"eventName" : customEventName};
    }
    
    [self logWithParameters:params];
    
}

- (void) tagEvent:(NSString*)eventName value:(NSString *)eventValue
{
    NSDictionary *params = @{@"eventName" : eventName,
                             @"eventValue" : eventValue};
 
    [self logWithParameters:params];
}


- (void) logWithParameters:(NSDictionary *)params
{
    [self.logging write:params
                message:@""
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
     {
         // TODO: Handle response.
         // Enqueue in case there was a failure.
     }];
}

@end
