//
//  SVHTTPClient.h
//
//  Created by Sam Vermette on 15.12.11.
//  Copyright 2011 samvermette.com. All rights reserved.
//
//  https://github.com/samvermette/SVHTTPRequest
//

#import <Foundation/Foundation.h>

typedef void (^SVHTTPRequestCompletionHandler)(id response, NSHTTPURLResponse *urlResponse, NSError *error);

@class SVHTTPRequest;

@interface SVHTTPClient : NSObject

+ (instancetype)sharedClient;
+ (instancetype)sharedClientWithIdentifier:(NSString*)identifier;

- (void)setBasicAuthWithUsername:(NSString*)username password:(NSString*)password;
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

- (SVHTTPRequest*)GET:(NSString*)path parameters:(NSDictionary*)parameters completion:(SVHTTPRequestCompletionHandler)completionBlock;
- (SVHTTPRequest*)GET:(NSString*)path parameters:(NSDictionary*)parameters saveToPath:(NSString*)savePath progress:(void (^)(float progress))progressBlock completion:(SVHTTPRequestCompletionHandler)completionBlock;

- (SVHTTPRequest*)POST:(NSString*)path parameters:(NSObject*)parameters completion:(SVHTTPRequestCompletionHandler)completionBlock;
- (SVHTTPRequest*)POST:(NSString*)path
                stream:(NSInputStream *)stream
            parameters:(NSDictionary *)parameters
            completion:(SVHTTPRequestCompletionHandler)completionBlock;

- (SVHTTPRequest*)POST:(NSString*)path parameters:(NSObject*)parameters progress:(void (^)(float progress))progressBlock completion:(void (^)(id response, NSHTTPURLResponse *urlResponse, NSError *error))completionBlock;
- (SVHTTPRequest*)PUT:(NSString*)path parameters:(NSObject*)parameters completion:(SVHTTPRequestCompletionHandler)completionBlock;

- (SVHTTPRequest*)DELETE:(NSString*)path parameters:(NSDictionary*)parameters completion:(SVHTTPRequestCompletionHandler)completionBlock;
- (SVHTTPRequest*)HEAD:(NSString*)path parameters:(NSDictionary*)parameters completion:(SVHTTPRequestCompletionHandler)completionBlock;

- (void)cancelRequestsWithPath:(NSString*)path;
- (void)cancelAllRequests;


@property (nonatomic, strong) NSDictionary *baseParameters;

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, copy) NSString *userAgent;

@property (nonatomic, readwrite) BOOL sendParametersAsJSON;
@property (nonatomic, readwrite) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, readwrite) NSUInteger timeoutInterval;

@property (nonatomic, readwrite) NSDictionary *headers;
@property (nonatomic, readwrite) BOOL dismissNSURLAuthenticationMethodServerTrust;

@end
