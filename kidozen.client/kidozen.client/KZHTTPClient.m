#import "KZHTTPClient.h"
#import "KZHTTPRequest.h"

@interface KZHTTPClient ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

- (void)queueRequest:(NSString*)path 
              method:(KZHTTPRequestMethod)method 
          parameters:(NSDictionary*)parameters 
          saveToPath:(NSString*)savePath 
            progress:(void (^)(float))progressBlock
          completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock;

@end


@implementation KZHTTPClient

@synthesize username, password, basePath, userAgent, sendParametersAsJSON, cachePolicy, operationQueue, headers;

@synthesize bypassSSLValidation = _bypassSSLValidation;

+ (KZHTTPClient*)sharedClient {
	
    static KZHTTPClient *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    self.operationQueue = [[NSOperationQueue alloc] init];
    return self;
}

#pragma mark - Setters


- (void)setBasicAuthWithUsername:(NSString *)newUsername password:(NSString *)newPassword {
    
    if(username)
        username = nil;
    
    if(password)
        password = nil;
    
    if(newUsername && newPassword) {
        username = newUsername;
        password = newPassword;
    }
}

#pragma mark - Request Methods

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodGET parameters:parameters saveToPath:nil progress:nil completion:completionBlock];
}

- (void)GET:(NSString *)path parameters:(NSDictionary *)parameters saveToPath:(NSString *)savePath progress:(void (^)(float))progressBlock completion:(void (^)(id, NSHTTPURLResponse*, NSError *))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodGET parameters:parameters saveToPath:savePath progress:progressBlock completion:completionBlock];
}

- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodPOST parameters:parameters saveToPath:nil progress:nil completion:completionBlock];
}

- (void)PUT:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodPUT parameters:parameters saveToPath:nil progress:nil completion:completionBlock];
}

- (void)DELETE:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodDELETE parameters:parameters saveToPath:nil progress:nil completion:completionBlock];
}

- (void)HEAD:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(id, NSHTTPURLResponse*, NSError*))completionBlock {
    [self queueRequest:path method:SVHTTPRequestMethodHEAD parameters:parameters saveToPath:nil progress:nil completion:completionBlock];
}

#pragma mark - Operation Cancelling

- (void)cancelRequestsWithPath:(NSString *)path {
    [self.operationQueue.operations enumerateObjectsUsingBlock:^(id request, NSUInteger idx, BOOL *stop) {
        NSString *requestPath = [request valueForKey:@"requestPath"];
        if([requestPath isEqualToString:path])
            [request cancel];
    }];
}

- (void)cancelAllRequests {
    [self.operationQueue cancelAllOperations];
}

#pragma mark -

- (void)queueRequest:(NSString*)path 
              method:(KZHTTPRequestMethod)method 
          parameters:(NSDictionary*)parameters 
          saveToPath:(NSString*)savePath 
            progress:(void (^)(float))progressBlock 
          completion:(void (^)(id, NSHTTPURLResponse*, NSError *))completionBlock  {
    
    NSString *completeURLString = [NSString stringWithFormat:@"%@%@", self.basePath, path];
    KZHTTPRequest *requestOperation = [(id<KZHTTPRequestPrivateMethods>)[KZHTTPRequest alloc] initWithAddress:completeURLString method:method parameters:parameters saveToPath:savePath progress:progressBlock completion:completionBlock];
    requestOperation.headers = self.headers;
    requestOperation.sendParametersAsJSON = self.sendParametersAsJSON;
    requestOperation.cachePolicy = self.cachePolicy;
    requestOperation.userAgent = self.userAgent;
    [requestOperation setBypassSSLValidation:_bypassSSLValidation];

    if(self.username && self.password)
        [(id<KZHTTPRequestPrivateMethods>)requestOperation signRequestWithUsername:self.username password:self.password];
    
    [(id<KZHTTPRequestPrivateMethods>)requestOperation setRequestPath:path];
    [self.operationQueue addOperation:requestOperation];
}

@end
