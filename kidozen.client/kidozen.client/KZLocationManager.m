//
//  KZLocationManager.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/16/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KZLocationManager.h"

#define DEFAULT_DISTANCE_FILTER 500

@interface KZLocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation KZLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = DEFAULT_DISTANCE_FILTER;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    }
    return self;
}

- (void) enableLocationMgr {
    
    if ( ([CLLocationManager locationServicesEnabled] == NO ||
          CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined ||
          CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
                    CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted) )
    {
        
        if ( [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Enable Location Services"
                                        message:@"Please enable Location Services for this application. Settings > Privacy > Location"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil] show];
        }
    }
    
    [self.locationManager startUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    __weak KZLocationManager *safeMe = self;
    
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
         if (!(error)) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             if (safeMe.didUpdateLocation != nil) {
                 safeMe.didUpdateLocation(placemark);
             }
             
         } else {
             NSLog(@"Geocode failed with error %@", error);
         }
     }];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ( ([CLLocationManager locationServicesEnabled] == YES ||
          CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized ||
          CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
          CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) )
    {
        [self.locationManager startUpdatingLocation];
    }
}


@end
