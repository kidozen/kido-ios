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


- (void)tagEvent:(NSString *)event
{
    [self tagEvent:event attributes:nil];
}

- (void)tagEvent:(NSString *)event
      attributes:(NSDictionary *)attributes
{
    attributes = attributes != nil ? attributes : @{};
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:attributes];
    [params addEntriesFromDictionary:@{@"Type": @"Event"}];
    [params addEntriesFromDictionary:self.deviceInfo.properties];
    
    [self.logging write:params
                message:event
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
    {
        NSLog(@"Logged is %@", response.response);
    }];
}

@end
