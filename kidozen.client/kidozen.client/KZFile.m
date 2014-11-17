//
//  KZFile.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 10/31/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//

#import "KZFile.h"
#import "KZTokenController.h"

@implementation KZFile

- (void) downloadFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block
{
    
}

- (void) uploadFileData:(NSData *)data callback:(void (^)(KZResponse *r))block
{



    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:@"https://tasks-tests.qa.kidozen.com/uploads/"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setValue:@"name.txt" forHTTPHeaderField:@"x-file-name"];
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:self.tokenController.kzToken forHTTPHeaderField:@"Authorization"];
    
    NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
    [request setHTTPBodyStream:stream];
    [request setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSLog(@"Finished with status code: %i", [(NSHTTPURLResponse *)response statusCode]);
                           }];
    
    
    
//    [self.client POST:"path"
//           parameters:nil // params?
//           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
//        
//    }];
}

- (void) deleteFilePath:(NSString *)filePath callback:(void (^)(KZResponse *))block
{
    
}

- (void) browseAtPath:(NSString *)path callback:(void (^)(KZResponse *))block
{
    
}

@end
