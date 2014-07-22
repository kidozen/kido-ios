//
//  Crasher.h
//  CrashSampleLib
//
//  Created by Nicolas Miyasato on 4/4/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crasher : NSObject

- (void)crashWithOutOfBounds;
- (void)crashThrowingException;
- (void)crashDivideByZero;
    
@end
