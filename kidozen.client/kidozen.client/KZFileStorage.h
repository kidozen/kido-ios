//
//  KZFileStorage.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZBaseService.h"

/**
 * This is the File Service, which will let you perform some operations such as
 * uploading, deleting, getting files from the cloud.
 */
@interface KZFileStorage : KZBaseService

/**
*  By Calling this method it'll download the file that it located in the filePath provided.
*
*  @param filePath This is the full path to the file you want to download.
*  It should not end with a '/', as it's a file
*
*  @param block will contain the KZResponse. If the file is found, 
*  it'll be an NSData form in the KZResponse.response property.
*/
- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;

/**
 *  This method will upload the data provided in the corresponding filePath.
 *
 *  @param data     It's the data representation of what you want to upload.
 *  @param filePath This is the full filepath you want the data to be uploaded.
 *  @param block    It's the callback method. In the response you can check if the file was
 *                  correctly uploaded.
 */
- (void) uploadFileData:(NSData *)data filePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;
- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block;

/**
 *  This method will return, in the response, the directories contained in the folder at path.
 *
 *  @param path  is the folder you wish to browse.
 *  @param block will contain a KZResponse instance, where in KZResponse.response you'll have a dictionary
 *  that contains the folder contents.
 */
- (void) browseAtPath:(NSString *)path callback:(void (^)(KZResponse *r))block;

@end
