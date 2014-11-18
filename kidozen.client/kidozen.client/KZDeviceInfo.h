//
//  KZDeviceInfo.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZObject.h"

@interface KZDeviceInfo : NSObject

+(instancetype) sharedDeviceInfo;

@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *systemVersion;

- (NSString *)carrierName;

- (NSDictionary *)properties;
- (NSString *) getUniqueIdentification;
- (void) enableGeoLocation;

@end
