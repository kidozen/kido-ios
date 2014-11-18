//
//  KZFile.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZBaseService.h"

/**
 * This is the File Service, which will let you perform some operations such as
 * uploading, deleting, getting files from the kidocloud.
 */
@interface KZFile : KZBaseService

- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;
- (void) uploadFileData:(NSData *)data filePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;
- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;
- (void) browseAtPath:(NSString *)path callback:(void (^)(KZResponse *r))block;

@end
