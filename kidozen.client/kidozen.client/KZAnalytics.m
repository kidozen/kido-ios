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
    [self tag:event type:@"Event" attributes:nil];
}

- (void)tagScreen:(NSString *)screen
{
    [self tag:screen type:@"Screen" attributes:nil];
}

- (void) tag:(NSString *)tag type:(NSString *)tagType attributes:(NSDictionary *)attributes
{
    attributes = attributes != nil ? attributes : @{};
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:attributes];
    
//    [params addEntriesFromDictionary:@{@"Type": tagType}];
    [params addEntriesFromDictionary:self.deviceInfo.properties];
    
    tag = [NSString stringWithFormat:@"%@.%@", tagType, tag];
    [self.logging write:params
                message:tag
              withLevel:LogLevelInfo
             completion:^(KZResponse *response)
     {
         // TODO: Handle response.
         // Enqueue in case there was a failure.
     }];

}

@end
