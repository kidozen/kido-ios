//
//  KZDeviceInfo.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZDeviceInfo.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "KZLocationManager.h"

@interface KZDeviceInfo()

@property (nonatomic, strong) CTCarrier *carrier;
@property (nonatomic, copy, readwrite) NSString *appVersion;
@property (nonatomic, copy, readwrite) NSString *deviceModel;
@property (nonatomic, copy, readwrite) NSString *systemVersion;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, readwrite, copy) NSString *isoCountryCode;
@property (nonatomic, strong) KZLocationManager *locationManager;

@end

@implementation KZDeviceInfo


+ (instancetype)sharedDeviceInfo {
    
    static KZDeviceInfo *sharedDevice = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDevice = [[self alloc] init];
    });
    return sharedDevice;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        self.reachability = [Reachability reachabilityForInternetConnection];
        self.carrier = [self configureCarrier];
        self.appVersion = [self configureAppVersion];
        
        [self configureDeviceInfo];
        
    }
    return self;
}

- (void) enableGeoLocation
{
    [self.locationManager enableLocationMgr];
}

- (void)configureDeviceInfo
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    self.deviceModel = currentDevice.model;
    self.systemVersion = currentDevice.systemVersion;
    
    self.isoCountryCode = @"Unknown";

    self.locationManager = [[KZLocationManager alloc] init];
    __weak KZDeviceInfo *safeMe = self;
    
    self.locationManager.didUpdateLocation = ^(CLPlacemark *placemark) {
        NSLog(@"Location is %@", placemark.ISOcountryCode);
        safeMe.isoCountryCode = placemark.ISOcountryCode;
    };

    
}
- (CTCarrier *)configureCarrier
{
    return self.networkInfo.subscriberCellularProvider;
}

- (NSString *)currentRadioAccessTechnology {
    if (self.reachability.isReachableViaWiFi == YES) {
        return @"WiFi";
    } else {
        return self.networkInfo.currentRadioAccessTechnology ?: @"Unknown";
    }
}

- (NSString *)carrierName
{
    return self.carrier.carrierName ?: @"Unknown";
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
             @"networkAccess": self.currentRadioAccessTechnology,
             @"isoCountryCode" : self.isoCountryCode,
             @"deviceModel" : self.deviceModel ? : @"Simulator",
             @"systemVersion" : self.systemVersion,
             @"uniqueId" : self.getUniqueIdentification
             };
}

- (NSString *)getUniqueIdentification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *uniqueID = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:@"kUniqueIdentificationFilename"];
    
    if (uniqueID == nil) {
        uniqueID = [[NSUUID UUID] UUIDString];
        [userDefaults setValue:uniqueID forKey:@"kUniqueIdentificationFilename"];
        [userDefaults synchronize];
    }
    
    return  uniqueID;
}

@end
