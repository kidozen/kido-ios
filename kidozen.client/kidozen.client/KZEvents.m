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
#import "KZEvent.h"

static NSString *const kEventsFilename = @"kEventsFilename";

@interface KZEvents()

@property (nonatomic, strong) NSMutableArray *events;

@end

@implementation KZEvents

+(instancetype)eventsFromDisk
{
    NSMutableArray *events = [NSMutableArray objectWithContentsOfFile:[kEventsFilename documentsPath]];
    KZEvents *allEvents = [[KZEvents alloc] initWithEvents:events];
    return allEvents;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.events = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype) initWithEvents:(NSMutableArray *)events {
    
    self = [self init];
    if (self) {
        if ([events count] > 0) {
            [self.events addObjectsFromArray:events];
        }
    }
    return self;
}

- (void)removeCurrentEvents {
    [self.events removeAllObjects];
}

- (void)save {
    NSString *eventsPathFilename = [kEventsFilename documentsPath];
    
    if (![self.events writeToFile:eventsPathFilename atomically:YES]) {
        NSLog(@"An error occured while saving the events. Could not write to %@", eventsPathFilename);
    }
}

- (void)addEvent:(KZEvent *)event {
    if (event) {        
        [self.events addObject:[event serializedEvent]];
    }
}

- (void)removeSavedEvents {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *eventsPath = [kEventsFilename documentsPath];
    
    if ([fm fileExistsAtPath:eventsPath]) {
        [fm removeItemAtPath:eventsPath error:nil];
    }
    
}
@end
