//
//  KZDeviceInfo.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/3/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZObject.h"


/**
 *  Provides device information that will be sent along the user-session event.
 */
@interface KZDeviceInfo : NSObject


// Singleton.
+(instancetype) sharedDeviceInfo;

 /**
 *  Your application version, which is in the app.info file.
 */
@property (nonatomic, copy, readonly) NSString *appVersion;

@property (nonatomic, copy, readonly) NSString *deviceModel; // e.g. @"iPhone", @"iPod touch"
@property (nonatomic, copy, readonly) NSString *systemVersion; // e.g. @"4.0"

/**
 *   The name of the subscriber's cellular service provider.
 */
- (NSString *)carrierName;

/**
 *  All device properties to be sent.
 */
- (NSDictionary *)properties;

/**
 *  Something like a MAC Address, though as Apple forbid the use of it, we 
 *  generate and persist one. If it exists on disk, we'll return it, otherwise
 *  we generate a new one.
 *
 *  @return A unique identifier that will identify this device.
 */
- (NSString *) getUniqueIdentification;

/**
 *  Will enable geolocation to know where the user is using the application.
 */
- (void) enableGeoLocation;

@end
