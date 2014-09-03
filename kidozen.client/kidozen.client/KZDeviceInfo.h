//
//  KZDeviceInfo.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/3/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZObject.h"

@interface KZDeviceInfo : KZObject

@property (nonatomic, copy, readonly) NSString *appVersion;
@property (nonatomic, copy, readonly) NSString *deviceModel;
@property (nonatomic, copy, readonly) NSString *systemVersion;

- (NSString *)carrierName;

- (NSDictionary *)properties;
- (NSString *) getUniqueIdentification;

@end
