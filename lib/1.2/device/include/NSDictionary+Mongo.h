//
//  NSDictionary+Mongo.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/8/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Mongo)

// Mongo does not allow dots in the key, so this method returns a
// value without dots for keys.
-(NSDictionary *) dictionaryWithoutDotsInKeys;

@end
