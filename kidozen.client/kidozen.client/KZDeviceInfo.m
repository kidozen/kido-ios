//
//  KZDeviceInfo.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/3/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZDeviceInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIKit.h>

@interface KZDeviceInfo()

@property (nonatomic, strong) CTCarrier *carrier;
@property (nonatomic, copy, readwrite) NSString *appVersion;
@property (nonatomic, copy, readwrite) NSString *deviceModel;
@property (nonatomic, copy, readwrite) NSString *systemVersion;

@end

@implementation KZDeviceInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.carrier = [self configureCarrier];
        self.appVersion = [self configureAppVersion];
        [self configureDeviceInfo];
        
    }
    return self;
}

- (void)configureDeviceInfo
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    self.deviceModel = currentDevice.model;
    self.systemVersion = currentDevice.systemVersion;
    
}
- (CTCarrier *)configureCarrier
{
    CTTelephonyNetworkInfo *myNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    return [myNetworkInfo subscriberCellularProvider];
}


- (NSString *)carrierName
{
    return self.carrier.carrierName;
}

- (NSString *)mobileCountryCode
{
    return self.carrier.mobileCountryCode;
}

- (NSString *)isoCountryCode
{
    return self.carrier.isoCountryCode;
}

- (NSString *)configureAppVersion
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (version == nil || [version isEqualToString:@""])
        version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    return version;
}

- (NSDictionary *)properties
{
    return @{@"carrierName": self.carrierName,
             @"mobileCountryCode" : self.mobileCountryCode,
             @"isoCountryCode" : self.isoCountryCode,
             @"deviceModel" : self.deviceModel,
             @"systemVersion" : self.systemVersion
             };
}

@end
