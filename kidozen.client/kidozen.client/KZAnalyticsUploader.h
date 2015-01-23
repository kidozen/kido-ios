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

/**
 * This class is in charge of uploading the analytics session when required.
 * You can also set it to upload every amount of seconds at most.
 */
@interface KZAnalyticsUploader : NSObject

/**
 *  Initializer. Needs the session to be uploaded and the logging service where
 *  all events are going to be sent.
 *
 *  @param session is what is going to be sent.
 *  @param logging The service where the events are going to be sent.
 *
 *  @return an instance of the uploader.
 */
- (instancetype) initWithSession:(KZAnalyticsSession *)session
                  loggingService:(KZLogging *)logging;


// There is a timer that will try to upload all current events every maximumSecondsToUpload.
// Defaults to 300 seconds (5 minutes)
@property (nonatomic, assign) NSUInteger maximumSecondsToUpload;

@end
