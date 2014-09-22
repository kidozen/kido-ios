//
//  KZAnalyticsUploader.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/18/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZAnalyticsSession;
@class KZLogging;

@interface KZAnalyticsUploader : NSObject

- (instancetype) initWithSession:(KZAnalyticsSession *)session
                  loggingService:(KZLogging *)logging;


// There is a timer that will try to upload all current events every maximumSecondsToUpload.
// Defaults to 300 seconds (5 minutes)
@property (nonatomic, assign) NSUInteger maximumSecondsToUpload;

@end
