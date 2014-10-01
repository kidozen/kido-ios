//
//  NSString+Path.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 9/16/14.
//  Copyright (c) 2014 Kidozen. All rights reserved.
//

#import "NSString+Path.h"

@implementation NSString(Path)

- (NSString *)documentsPath
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [pathArray objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:self];
    
}

@end
