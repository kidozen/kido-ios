//
//  KZLocationManager.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/16/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZLocationManager.h"

#define DEFAULT_DISTANCE_FILTER 100

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
        [self.locationManager startUpdatingLocation];
        
    }
    return self;
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

@end
