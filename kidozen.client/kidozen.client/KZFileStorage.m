//
//  KZFileStorage.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

#import "KZFileStorage.h"
#import "KZTokenController.h"
#import "KZBaseService+ProtectedMethods.h"
#import "NSString+Path.h"

@implementation KZFileStorage

- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block
{
    
    filePath = [self sanitizePath:filePath isDirectory:NO];
    
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [self addAuthorizationHeader];
    
    __weak KZFileStorage *safeMe = self;
    
    [self.client GET:filePath parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
    }];
    
}

- (void) uploadFileData:(NSData *)data filePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block
{
    
    filePath = [self sanitizePath:filePath isDirectory:NO];
    
    NSDictionary *parameters = @{@"x-file-name" : [filePath onlyFilename] };
    NSInputStream *stream = [[NSInputStream alloc] initWithData:data];

    __weak KZFileStorage *safeMe = self;
    
    [self addAuthorizationHeader];
    NSString *path = [filePath directoriesFullPath];
    [self.client POST:path
               stream:stream
           parameters:parameters
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
            }];
}

- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *r))block
{
    filePath = [self sanitizePath:filePath isDirectory:NO];
    
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [self addAuthorizationHeader];
    
    __weak KZFileStorage *safeMe = self;
    
    [self.client DELETE:filePath parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
    }];

}

- (void) browseAtPath:(NSString *)filePath callback:(void (^)(KZResponse *r))block
{
    filePath = [self sanitizePath:filePath isDirectory:YES];
    
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Pragma"];
    [self.client setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    [self addAuthorizationHeader];
    
    __weak KZFileStorage *safeMe = self;
    
    [self.client GET:filePath parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
    }];

}


// This method will sanitize the filePath for this particular use case.
// If it's a directory, it should start with a '/' and end with a '/'
// Otherwise, it should start with '/' and NOT end with '/'
- (NSString *)sanitizePath:(NSString *)filePath isDirectory:(BOOL)isDirectory {
    if ([filePath length] == 0) {
        [NSException raise:NSInvalidArgumentException format:@"FilePath must not be empty."];
    }
    
    NSString *path = [filePath stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];

    
    if (![filePath hasPrefix:@"/"]) {
        path = [NSString stringWithFormat:@"/%@", path];
    }
    
    if (isDirectory == YES) {
        if (![filePath hasSuffix:@"/"]) {
            path = [NSString stringWithFormat:@"%@/", path];
        }
    }
    
    return path;
    
    
}

@end
