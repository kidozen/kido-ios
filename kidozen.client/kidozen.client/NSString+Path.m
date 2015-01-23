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

// filePath contains the directory and the filename, such as
// /uploadedFiles/November/presentation.txt
// It'll return /uploadedFiles/November
- (NSString *)directoriesFullPath {
    NSArray *components = [self componentsSeparatedByString:@"/"];
    if (components.count > 0) {
        NSArray *subComponents = [components subarrayWithRange:NSMakeRange(0, components.count - 1)];
        return [subComponents componentsJoinedByString:@"/"];
    } else {
        return [self copy];
    }
}

// Just returns the last string component.
- (NSString *)onlyFilename {
    NSArray *components = [self componentsSeparatedByString:@"/"];
    return (NSString *)[components lastObject];
}

@end
