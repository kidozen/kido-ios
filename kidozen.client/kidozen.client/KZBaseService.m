#import "KZBaseService.h"
#import "KZWRAPv09IdentityProvider.h"

#define ENULLPARAM       1

NSInteger const KZHttpErrorStatusCode = 300;
NSString * const KZServiceErrorDomain = @"KZServiceErrorDomain";


@interface KZBaseService (private)
{
}
-(NSError *) createNilReferenceError;
@end

@implementation KZBaseService

@synthesize name = _name;
@synthesize serviceUrl = _serviceUrl;
@synthesize kzToken = _kzToken;
@synthesize KidoZenUser = _kzUser;
@synthesize ipToken = _ipToken;

-(id) initWithEndpoint:(NSString *)endpoint andName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        _name = name;
        _endpoint = endpoint;
        
        _serviceUrl = [NSURL URLWithString:_endpoint] ;
        _client = [[KZHTTPClient alloc] init]; 
        [_client setBasePath:_serviceUrl.absoluteString];
    }
    return self;
}

-(void) setBypassSSL:(BOOL)bypass
{
    _bypassSSL = bypass;
    [_client setBypassSSLValidation:bypass];
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

@end
