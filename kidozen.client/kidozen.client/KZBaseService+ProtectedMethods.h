//
//  KZBaseService+ProtectedMethods.h
//  kidozen.client
//
//  Created by Nicolas Miyasato on 7/16/14.
//  Copyright (c) 2014 Tellago Studios. All rights reserved.
//


@interface KZBaseService (ProtectedMethods)

- (void) callCallback:(void (^)(KZResponse *))block
             response:(id)response
          urlResponse:(NSHTTPURLResponse *)urlResponse
                error:(NSError *)error;

@end
