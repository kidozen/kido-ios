//
//  KZGoodIdentityProvider.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 3/2/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZIdentityProvider.h"

extern NSString *const kChallengeKey;

@interface KZGoodIdentityProvider : NSObject  <KZIdentityProvider>

@property (nonatomic, assign) BOOL strictSSL;

@end
