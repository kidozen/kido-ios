//
//  KZObject.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZObject.h"
#import <objc/runtime.h>

@interface KZObject()

@property (nonatomic, strong) NSDictionary *propertiesMapper;

@end


@implementation KZObject

// Dictionary should be a JSON parsed object, which comes from the
// kidozen servers.
// As you can see in the implementation, the main idea is to dynamically
// setup an object, mapping the dictionary keys to the object's properties.
- (void) configureWithDictionary:(NSDictionary *)dictionary
{
    NSDictionary *propertyToClassDictionary = [self propertiesWithClassesDictionary];
    for (NSString *key in [dictionary allKeys])
    {
        NSString *mappedKey = [self.propertiesMapper objectForKey:key] ?: key;
        NSString *stringClass = [propertyToClassDictionary objectForKey:mappedKey];
        
        Class klass = NSClassFromString(stringClass);
        if ([self respondsToSelector:NSSelectorFromString(mappedKey)]) {
            if ([klass isSubclassOfClass:[KZObject class]] ) {
                
                id dmObjectInstance = [[klass alloc] initWithDictionary:[dictionary objectForKey:key]];
                [self setValue:dmObjectInstance forKey:mappedKey];
                
            } else {
                [self setValue:[dictionary objectForKey:key] forKey:mappedKey];
            }
        } else {
//            NSLog(@"warning - %@ not as a property", mappedKey);
        }
    }
}

/*
 This method will return a dictionary with all properties of the current
 class as keys, with their values being their corresponding string class.
 propertyMapper[@"age"] -->  @"NSNumber";
 propertyMapper[@"name"] --> @"NSString";
 */
-(NSDictionary*) propertiesWithClassesDictionary {
    
    objc_property_t *propertyList;
    NSMutableDictionary *propertyMapper = [NSMutableDictionary dictionary];
    
    Class currentClass = [self class];
    
    unsigned int propertyCount = 0;
    
    // We need to manually ask each and every superclass for their properties
    // because of class_copyPropertyList
    while ([currentClass isSubclassOfClass:[KZObject class]]) {
        
        // The class_copyPropertyList method will give me an NULL terminated array
        // of pointers to properties (which type is objc_propety_t of the current
        // class, EXCLUDING superclasses.
        propertyList = class_copyPropertyList(currentClass, &propertyCount);
        
        for (int i=0; i < propertyCount; i++) {
            
            // Getting the propertyName
            objc_property_t * oneProperty = propertyList + i;
            NSString *propertyName =  [NSString stringWithUTF8String:property_getName(*oneProperty)];
            
            // Getting the property class.
            NSString *stringClass = [NSString stringWithUTF8String:property_copyAttributeValue(*oneProperty, "T")];

            // removing @" characters.
            [propertyMapper setValue:[[stringClass stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"@" withString:@""]
                              forKey:propertyName];
            
        }
        
        free(propertyList);
        currentClass = [currentClass superclass];
        
    }
    
    return propertyMapper;
}

@end
