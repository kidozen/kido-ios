#import "KZHTTPRequest.h"

#define kSVHTTPRequestTimeoutInterval 100

@interface NSData (Base64)
- (NSString*)base64EncodingWithLineLength:(unsigned int)lineLength;
@end

@interface NSString (OAURLEncodingAdditions)
- (NSString*)encodedURLParameterString;
@end

enum {
    SVHTTPRequestStateReady = 0,
    SVHTTPRequestStateExecuting,
    SVHTTPRequestStateFinished
};

typedef NSUInteger SVHTTPRequestState;

@interface KZHTTPRequest ()

@property (nonatomic, strong) NSMutableURLRequest *operationRequest;
@property (nonatomic, strong) NSMutableData *operationData;
@property (nonatomic, strong) NSFileHandle *operationFileHandle;
@property (nonatomic, strong) NSURLConnection *operationConnection;
@property (nonatomic, strong) NSDictionary *operationParameters;
@property (nonatomic, strong) NSHTTPURLResponse *operationURLResponse;
@property (nonatomic, strong) NSString *operationSavePath;

@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;
@property (nonatomic, copy) void (^operationCompletionBlock)(id response, NSHTTPURLResponse *urlResponse, NSError *error);
@property (nonatomic, copy) void (^operationProgressBlock)(float progress);

@property (nonatomic, readwrite) SVHTTPRequestState state;
@property (nonatomic, strong) NSString *requestPath;

@property (nonatomic, strong) NSTimer *timeoutTimer; // see http://stackoverflow.com/questions/2736967

@property (nonatomic, readwrite) float expectedContentLength;
@property (nonatomic, readwrite) float receivedContentLength;

- (void)addParametersToRequest:(NSDictionary*)paramsDict;
- (void)finish;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)callCompletionBlockWithResponse:(id)response error:(NSError *)error;

@end


@implementation KZHTTPRequest

// public properties
@synthesize sendParametersAsJSON, cachePolicy, headers, bodyStream;

// private properties
@synthesize operationRequest, operationData, operationConnection, operationParameters, operationURLResponse, operationFileHandle, state;
@synthesize operationSavePath, operationCompletionBlock, operationProgressBlock, timeoutTimer;
@synthesize expectedContentLength, receivedContentLength, saveDataDispatchGroup, saveDataDispatchQueue;
@synthesize requestPath, userAgent;
@synthesize bypassSSLValidation = _bypassSSLValidation;

- (void)dealloc {
    [operationConnection cancel];
#if NEEDS_DISPATCH_RETAIN_RELEASE
    dispatch_release(saveDataDispatchGroup);
    dispatch_release(saveDataDispatchQueue);
#endif
    
#if !TARGET_OS_MAC && !TARGET_OS_IPHONE && !TARGET_OS_EMBEDDED && !TARGET_IPHONE_SIMULATOR
    [super dealloc];
#endif
}

#pragma mark - Convenience Methods

+ (KZHTTPRequest*)GET:(NSString *)address parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))block {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodGET parameters:parameters saveToPath:nil progress:nil completion:block];
    [requestObject start];
    
    return requestObject;
}

+ (KZHTTPRequest*)GET:(NSString *)address parameters:(NSDictionary *)parameters saveToPath:(NSString *)savePath progress:(void (^)(float))progressBlock completion:(void (^)(id, NSHTTPURLResponse*, NSError *))completionBlock {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodGET parameters:parameters saveToPath:savePath progress:progressBlock completion:completionBlock];
    [requestObject start];
    
    return requestObject;
}

+ (KZHTTPRequest*)POST:(NSString *)address parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))block {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodPOST parameters:parameters saveToPath:nil progress:nil completion:block];
    if (requestObject.bodyStream) {
        [requestObject setBodyStream:requestObject.bodyStream];
    }
    
    [requestObject start];
    
    return requestObject;
}

+ (KZHTTPRequest*)PUT:(NSString *)address parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))block {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodPUT parameters:parameters saveToPath:nil progress:nil completion:block];
    [requestObject start];
    
    return requestObject;
}

+ (KZHTTPRequest*)DELETE:(NSString *)address parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))block {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodDELETE parameters:parameters saveToPath:nil progress:nil completion:block];
    [requestObject start];
    
    return requestObject;
}

+ (KZHTTPRequest*)HEAD:(NSString *)address parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse *, NSError *))block {
    KZHTTPRequest *requestObject = [[self alloc] initWithAddress:address method:SVHTTPRequestMethodHEAD parameters:parameters saveToPath:nil progress:nil completion:block];
    [requestObject start];
    
    return requestObject;
}

#pragma mark -

- (KZHTTPRequest*)initWithAddress:(NSString *)urlString method:(KZHTTPRequestMethod)method parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError *))completionBlock {
    return [(id<KZHTTPRequestPrivateMethods>)self initWithAddress:urlString method:method parameters:parameters saveToPath:nil progress:NULL completion:completionBlock];
}

- (KZHTTPRequest*)initWithAddress:(NSString*)urlString method:(KZHTTPRequestMethod)method parameters:(NSDictionary*)parameters saveToPath:(NSString*)savePath progress:(void (^)(float))progressBlock completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock  {
    self = [super init];
    self.operationCompletionBlock = completionBlock;
    self.operationProgressBlock = progressBlock;
    self.operationSavePath = savePath;
    self.operationParameters = parameters;
    self.saveDataDispatchGroup = dispatch_group_create();
    self.saveDataDispatchQueue = dispatch_queue_create("com.samvermette.SVHTTPRequest", DISPATCH_QUEUE_SERIAL);
    
    self.operationRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.operationRequest setTimeoutInterval:kSVHTTPRequestTimeoutInterval];
    
    if(method == SVHTTPRequestMethodGET)
        [self.operationRequest setHTTPMethod:@"GET"];
    else if(method == SVHTTPRequestMethodPOST )
        [self.operationRequest setHTTPMethod:@"POST"];
    else if(method == SVHTTPRequestMethodPUT)
        [self.operationRequest setHTTPMethod:@"PUT"];
    else if(method == SVHTTPRequestMethodDELETE)
        [self.operationRequest setHTTPMethod:@"DELETE"];
    else if(method == SVHTTPRequestMethodHEAD)
        [self.operationRequest setHTTPMethod:@"HEAD"];
    self.state = SVHTTPRequestStateReady;
    
    return self;
}


- (void)addParametersToRequest:(NSDictionary*)paramsDict {
    
    NSUInteger parameterCount = [[paramsDict allKeys] count];
    
    NSMutableArray *stringParameters = [NSMutableArray arrayWithCapacity:parameterCount];
    NSMutableArray *dataParameters = [NSMutableArray arrayWithCapacity:parameterCount];
    NSString *method = self.operationRequest.HTTPMethod;
    
    [paramsDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if([obj isKindOfClass:[NSString class]]) {
            NSString *cleanParameter = [obj encodedURLParameterString];
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, cleanParameter]];
        } 
        
        else if([obj isKindOfClass:[NSNumber class]]) {
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        } 
        
        else if([obj isKindOfClass:[NSData class]]) {
            if(![method isEqualToString:@"POST"] && ![method isEqualToString:@"PUT"]) {
                exit(0);
            }
            
            NSString *dataBoundaryString = @"SVHTTPRequestBoundary";
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", dataBoundaryString];
            [self.operationRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
            
            NSMutableData *data = [NSMutableData data];
            [data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", dataBoundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"userfile\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[NSData dataWithData:obj]];
            [data appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", dataBoundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
            [dataParameters addObject:data];
        }
    }];
    
    NSString *parameterString = [stringParameters componentsJoinedByString:@"&"];
    
    if([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"]) {
        NSString *baseAddress = self.operationRequest.URL.absoluteString;
        baseAddress = [baseAddress stringByAppendingFormat:@"?%@", [stringParameters componentsJoinedByString:@"&"]];
        [self.operationRequest setURL:[NSURL URLWithString:baseAddress]];
    }
    else  {
        if(self.sendParametersAsJSON) {
            NSError *jsonError;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsDict options:0 error:&jsonError];
            if(jsonData && jsonError)
                [NSException raise:NSInvalidArgumentException format:@"Request parameters couldn't be serialized into JSON."];
            [self.operationRequest setHTTPBody:jsonData];
            [self.operationRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [self.operationRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [self.operationRequest setValue:[NSString stringWithFormat:@"%ld",(long) [jsonData length]] forHTTPHeaderField:@"Content-Length"];
        }
        else
        {
            const char *stringData = [parameterString UTF8String];
            NSMutableData *postData = [NSMutableData dataWithBytes:stringData length:strlen(stringData)];
            for(NSData *fileData in dataParameters)
                [postData appendData:fileData];
        
            [self.operationRequest setHTTPBody:postData];
        }
    }
}

- (void)signRequestWithUsername:(NSString*)username password:(NSString*)password  {
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:140]];
    [self.operationRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
}


- (void)setTimeoutTimer:(NSTimer *)newTimer {
    
    if(timeoutTimer)
        [timeoutTimer invalidate], timeoutTimer = nil;
    
    if(newTimer)
        timeoutTimer = newTimer;
}

#pragma mark - NSOperation methods

- (void)start {
    
    if(self.isCancelled) {
        [self finish];
        return;
    }
    
    if(![NSThread isMainThread]) { // NSOperationQueue calls start from a bg thread (through GCD), but NSURLConnection already does that by itself
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
#if TARGET_OS_IPHONE
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#endif
    if (self.headers) {
        [self.operationRequest setAllHTTPHeaderFields:self.headers];
    }

    if(self.operationParameters)
        [self addParametersToRequest:self.operationParameters];
    
    if(self.userAgent)
        [self.operationRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = SVHTTPRequestStateExecuting;    
    [self didChangeValueForKey:@"isExecuting"];
    
    if(self.operationSavePath) {
        [[NSFileManager defaultManager] createFileAtPath:self.operationSavePath contents:nil attributes:nil];
        self.operationFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.operationSavePath];
    } else {
        self.operationData = [[NSMutableData alloc] init];
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kSVHTTPRequestTimeoutInterval target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    }
    
    [self.operationRequest setCachePolicy:self.cachePolicy];
    self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest delegate:self startImmediately:NO];

    
    if(self.operationSavePath) // schedule on main run loop so scrolling doesn't prevent UI updates of the progress block
        [self.operationConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.operationConnection start];
    
#if !(defined SVHTTPREQUEST_DISABLE_LOGGING)
    //DLog(@"[%@] %@", self.operationRequest.HTTPMethod, self.operationRequest.URL.absoluteString);
#endif
}

// private method; not part of NSOperation
- (void)finish {
    [self.operationConnection cancel];
    operationConnection = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = SVHTTPRequestStateFinished;    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel {
    if([self isFinished])
        return;
    
    [super cancel];
    [self callCompletionBlockWithResponse:nil error:nil];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isFinished {
    return self.state == SVHTTPRequestStateFinished;
}

- (BOOL)isExecuting {
    return self.state == SVHTTPRequestStateExecuting;
}

#pragma mark -
#pragma mark Delegate Methods

- (void)requestTimeout {
    NSError *timeoutError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
    [self connection:nil didFailWithError:timeoutError];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.expectedContentLength = response.expectedContentLength;
    self.receivedContentLength = 0;
    self.operationURLResponse = (NSHTTPURLResponse*)response;
}


- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (_bypassSSLValidation) {
            NSURLProtectionSpace * protectionSpace = [challenge protectionSpace];
            NSURLCredential* credentail = [NSURLCredential credentialForTrust:[protectionSpace serverTrust]];
            [[challenge sender] useCredential:credentail forAuthenticationChallenge:challenge];
            //[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
        else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    dispatch_group_async(self.saveDataDispatchGroup, self.saveDataDispatchQueue, ^{
        if(self.operationSavePath) {
            @try { //writeData: can throw exception when there's no disk space. Give an error, don't crash
                [self.operationFileHandle writeData:data];
            }
            @catch (NSException *exception) {
                [self.operationConnection cancel];
                NSError *writeError = [NSError errorWithDomain:@"SVHTTPRequestWriteError" code:0 userInfo:exception.userInfo];
                [self callCompletionBlockWithResponse:nil error:writeError];
            }
        }
        else
            [self.operationData appendData:data];
    });
    
    if(self.operationProgressBlock) {
        //If its -1 that means the header does not have the content size value
        if(self.expectedContentLength != -1) {
            self.receivedContentLength += data.length;
            self.operationProgressBlock(self.receivedContentLength/self.expectedContentLength);
        } else {
            //we dont know the full size so always return -1 as the progress
            self.operationProgressBlock(-1);
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    dispatch_group_notify(self.saveDataDispatchGroup, dispatch_get_main_queue(), ^{
        id response = nil;
        NSError *JSONError = nil;
        if(self.operationData && self.operationData.length > 0) {
            response = [NSData dataWithData:self.operationData];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:&JSONError];
            
            if(jsonObject)
                response = jsonObject;
        }
        
        [self callCompletionBlockWithResponse:response error:JSONError];
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self callCompletionBlockWithResponse:nil error:error];
}

- (void)callCompletionBlockWithResponse:(id)response error:(NSError *)error {
    self.timeoutTimer = nil;
    
#if TARGET_OS_IPHONE
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
#endif
    
    if(self.operationCompletionBlock && !self.isCancelled)
        self.operationCompletionBlock(response, self.operationURLResponse, error);
    
    [self finish];
}

@end


// Created by Jon Crosby on 10/19/07.
// Copyright 2007 Kaboomerang LLC. All rights reserved.

@implementation NSString (SVHTTPRequest)

- (NSString*)encodedURLParameterString {
    NSString *result = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                            (__bridge CFStringRef)self,
                                                                                            NULL,
                                                                                            CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                                            kCFStringEncodingUTF8);
	return result;
}

@end

// Created by khammond on Mon Oct 29 2001.
// Formatted by Timothy Hatcher on Sun Jul 4 2004.
// Copyright (c) 2001 Kyle Hammond. All rights reserved.
// Original development by Dave Winer.

static char encodingTable[64] = {
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
    'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
    'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
    'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/' };

@implementation NSData (SVHTTPRequest)

- (NSString *)base64EncodingWithLineLength:(unsigned int) lineLength {
	const unsigned char	*bytes = [self bytes];
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
	unsigned long ixtext = 0;
	unsigned long lentext = [self length];
	long ctremaining = 0;
	unsigned char inbuf[3], outbuf[4];
	short i = 0;
	unsigned int charsonline = 0;
    short ctcopy = 0;
	unsigned long ix = 0;
    
	while( YES ) {
		ctremaining = lentext - ixtext;
		if( ctremaining <= 0 ) break;
        
		for( i = 0; i < 3; i++ ) {
			ix = ixtext + i;
			if( ix < lentext ) inbuf[i] = bytes[ix];
			else inbuf [i] = 0;
		}
        
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
		outbuf [3] = inbuf [2] & 0x3F;
		ctcopy = 4;
        
		switch( ctremaining ) {
            case 1: 
                ctcopy = 2; 
                break;
            case 2: 
                ctcopy = 3; 
                break;
		}
        
		for( i = 0; i < ctcopy; i++ )
			[result appendFormat:@"%c", encodingTable[outbuf[i]]];
        
		for( i = ctcopy; i < 4; i++ )
			[result appendFormat:@"%c",'='];
        
		ixtext += 3;
		charsonline += 4;
	}
    
	return result;
}

@end


