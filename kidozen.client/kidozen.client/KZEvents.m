//
//  KZEvents.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "KZEvents.h"
#import "NSString+Path.h"
#import "AutoCoding.h"

static NSString *const kEventsFilename = @"kEventsFilename";

@interface KZEvents()

@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation KZEvents

+(instancetype)eventsFromDisk {
    
    NSMutableArray *events = [NSMutableArray objectWithContentsOfFile:[kEventsFilename documentsPath]];
    
    KZEvents *allEvents = [[KZEvents alloc] initWithEvents:events];
    return allEvents;
}

- (instancetype) initWithEvents:(NSMutableArray *)events {
    
    self = [super init];
    if (self) {
        if (events) {
            self.events = events;
        } else {
            self.events = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)save {
    NSString *eventsPathFilename = [kEventsFilename documentsPath];
    [self.events writeToFile:eventsPathFilename atomically:YES];
}

- (void)addEvent:(KZEvent *)event {
    if (event) {
        [self.events addObject:event];
    }
}

@end
