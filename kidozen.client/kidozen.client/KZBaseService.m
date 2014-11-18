#import "KZBaseService.h"
#import "KZWRAPv09IdentityProvider.h"
#import "KZTokenController.h"
#import "KZBaseService+ProtectedMethods.h"
#import "NSData+Conversion.h"

#define ENULLPARAM       1

NSInteger const KZHttpErrorStatusCode = 300;
NSString * const KZServiceErrorDomain = @"KZServiceErrorDomain";


@interface KZBaseService ()

@property (nonatomic, copy, readwrite) NSString *endpoint;
@property (nonatomic, copy, readwrite) NSString * name;

@property (nonatomic, strong) SVHTTPClient *client;
@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, strong) NSURL * serviceUrl;

-(NSError *) createNilReferenceError;

@end

@implementation KZBaseService

-(id) initWithEndpoint:(NSString *)endpoint andName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.endpoint = endpoint;
        self.serviceUrl = [NSURL URLWithString:self.endpoint] ;
        
        self.client = [[SVHTTPClient alloc] init];
        [self.client setBasePath:self.serviceUrl.absoluteString];
        self.client.sendParametersAsJSON = YES;
    }
    return self;
}

-(void) setStrictSSL:(BOOL)strictSSL
{
    _strictSSL= strictSSL;
    [self.client setDismissNSURLAuthenticationMethodServerTrust:!strictSSL];
}

-(NSError *) createNilReferenceError
{
    NSDictionary *details = [NSDictionary
                             dictionaryWithObject:@"Parameter must not be nil"
                             forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:KZServiceErrorDomain code:ENULLPARAM userInfo:details];
}

- (void)addAuthorizationHeader
{
    if (self.tokenController != nil && self.tokenController.kzToken != nil && self.tokenController.kzToken.length > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.client.headers];
        headers[@"Authorization"] = self.tokenController.kzToken;
        [self.client setHeaders:headers];
    } else {
        NSLog(@"WARNING - NO AUTH HEADER");
    }
}

- (void) callCallback:(void (^)(KZResponse *))block
             response:(id)response
          urlResponse:(NSHTTPURLResponse *)urlResponse
                error:(NSError *)error
{
    if (block)
    {
        NSError * restError = error;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode && restError == nil) {
            NSString *msg = [response isKindOfClass:[NSData class]] ? [response KZ_UTF8String] : response;
            restError = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{@"Message": msg}];
        }
        
        id typedResponse = response;
        if ([response isKindOfClass:[NSData class]]) {
            NSString *utf8String = [response KZ_UTF8String];
            
            if (utf8String != nil) {
                typedResponse = utf8String;
            }

        } else {
            typedResponse = response;
        }
        
        block( [[KZResponse alloc] initWithResponse:typedResponse urlResponse:urlResponse andError:restError] );
    }
}


@end
