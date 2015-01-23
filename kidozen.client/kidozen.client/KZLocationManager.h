//
//  KZLocationManager.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/16/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

// This class will tell us the country in which we are.
// For now, we only need this use case.
@interface KZLocationManager : NSObject

@property (nonatomic, readonly) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^didUpdateLocation)(CLPlacemark *placemark);

- (void) enableLocationMgr;

@end
