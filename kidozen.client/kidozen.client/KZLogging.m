#import "KZLogging.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZLogging

- (NSString *)pathForLevel:(LogLevel)level message:(NSString *)message
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"?level=%d", level];
    
    if (message != nil && [message length] > 0) {
        [path appendFormat:@"&message=%@", message];
    }
    return path;
}

-(void) write:(id)object message:(NSString *)message withLevel:(LogLevel)level completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    NSString *path = [self pathForLevel:level message:message];
    
    __weak KZLogging *safeMe = self;
    
    [self.client POST:path
       parameters:object
       completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
           
               [safeMe callCallback:block
                           response:response
                        urlResponse:urlResponse
                              error:error];
           
    }];
}

-(void) write:(id)object withLevel:(LogLevel) level completion:(void (^)(KZResponse *))block
{
    [self write:object message:nil withLevel:level completion:block];
}

-(void) all:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZLogging *safeMe = self;
    
    [self.client GET:@"/"
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [safeMe callCallback:block
                          response:response
                       urlResponse:urlResponse
                             error:error];
              
          }];
    
}
-(void) clear:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZLogging *safeMe = self;
    
    [self.client DELETE:@"/"
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {

                 [safeMe callCallback:block
                             response:response
                          urlResponse:urlResponse
                                error:error];
                 
             }];

}
-(void) query:(NSString *)query andBlock:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    NSDictionary *parameters = @{@"query": query};
    __weak KZLogging *safeMe = self;
    
    [self.client GET:@"/"
          parameters:parameters
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [safeMe callCallback:block
                          response:response
                       urlResponse:urlResponse
                             error:error];
              
          }];
}

@end
