//
//  KZEvents.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KZEvent;

@interface KZEvents : NSObject

+(instancetype)eventsFromDisk;

@property (nonatomic, readonly) NSMutableArray *events;

- (void)removeSavedEvents;
- (void)addEvent:(KZEvent *)event;
- (void)save;
- (void)removeCurrentEvents;

@end
