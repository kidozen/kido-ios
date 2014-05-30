//
//  KZObject.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 5/29/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KZObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)configureWithDictionary:(NSDictionary *)dictionary;

// This dictionary should be used in case of the json coming from the server
// has keys with prohibited chars, such as '-'
@property (nonatomic, readonly) NSDictionary *propertiesMapper;

@end
