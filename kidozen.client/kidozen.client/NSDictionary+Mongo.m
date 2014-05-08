//
//  NSDictionary+Mongo.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/8/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "NSDictionary+Mongo.h"

@implementation NSDictionary (Mongo)

-(NSDictionary *) dictionaryWithoutDotsInKeys
{
    NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([key isKindOfClass:[NSString class]]) {
            key = [key stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [obj dictionaryWithoutDotsInKeys];
        }
        
        sanitizedDictionary[key] = obj;
        
    }];
    
    return sanitizedDictionary;
}

@end
