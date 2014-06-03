#import "KZBaseService.h"
#import "KZWRAPv09IdentityProvider.h"
#import "KZTokenController.h"

#define ENULLPARAM       1

NSInteger const KZHttpErrorStatusCode = 300;
NSString * const KZServiceErrorDomain = @"KZServiceErrorDomain";


@interface KZBaseService (private)

-(NSError *) createNilReferenceError;

@end

@implementation KZBaseService

-(id) initWithEndpoint:(NSString *)endpoint andName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name = name;
        _endpoint = endpoint;
        
        _serviceUrl = [NSURL URLWithString:_endpoint] ;
        _client = [[SVHTTPClient alloc] init];
        [_client setBasePath:_serviceUrl.absoluteString];
        _client.sendParametersAsJSON = YES;   
    }
    return self;
}

-(void) setBypassSSL:(BOOL)bypass
{
    _bypassSSL = bypass;
    [_client setDismissNSURLAuthenticationMethodServerTrust:bypass];
}

-(BOOL) bypassSSL
{
    return _bypassSSL;
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
    if (self.tokenControler != nil && self.tokenControler.kzToken != nil && self.tokenControler.kzToken.length > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:_client.headers];
        headers[@"Authorization"] = self.tokenControler.kzToken;
        [_client setHeaders:headers];
    }
}

@end
