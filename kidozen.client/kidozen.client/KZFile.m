//
//  KZFile.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZFile.h"
#import "KZTokenController.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZFile

- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block
{
    
}

- (void) uploadFileData:(NSData *)data filename:(NSString *)filename callback:(void (^)(KZResponse *r))block
{

    NSDictionary *parameters = @{@"x-file-name" : filename };
    
    NSInputStream *stream = [[NSInputStream alloc] initWithData:data];

    __weak KZFile *safeMe = self;
    
    [self addAuthorizationHeader];
    
    [self.client POST:@"" // TODO: Path for upload.
               stream:stream
           parameters:parameters
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
            }];
}

- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block
{
    
}

- (void) browseAtPath:(NSString *)path callback:(void (^)(KZResponse *))block
{
    
}

@end
