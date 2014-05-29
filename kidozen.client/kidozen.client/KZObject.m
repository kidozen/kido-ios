//
//  KZObject.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZObject.h"

@interface KZObject()

@property (nonatomic, strong) NSDictionary *propertiesMapper;

@end


@implementation KZObject

- (void) initializeWithDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in [dictionary allKeys]) {
        
        NSString *mappedKey = [self.propertiesMapper objectForKey:key] ?: key;
        
        @try {
            [self setValue:dictionary[key] forKey:mappedKey];
        }
        @catch (NSException *exception) {
            NSLog(@"Warning - The property %@ does not exist. Class is %@", key, [dictionary[key] class]);
        }
    }
}

@end
