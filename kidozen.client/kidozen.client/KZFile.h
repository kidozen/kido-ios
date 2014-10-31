//
//  KZFile.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZBaseService.h"

@interface KZFile : KZBaseService

- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block;
- (void) uploadFileData:(NSData *)data callback:(void (^)(KZResponse *))block;
- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block;
- (void) browseAtPath:(NSString *)path callback:(void (^)(KZResponse *))block;

@end
