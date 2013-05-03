#import "KZWRAPv09IdentityProvider.h"
#import "NSString+Utilities.h"

@interface KZWRAPv09IdentityProvider (private)
- (NSString *) getAssert:(NSString *) text;
@end

@implementation KZWRAPv09IdentityProvider 

@synthesize bypassSSLValidation = _bypassSSLValidation;

-(void) configure:(id) configuration
{
    
}
-(void) initializeWithUserName:(NSString *)user password:(NSString *) password andScope:(NSString *) scope
{
    _wrapName = user;
    _wrapPassword = password;
    _wrapScope = scope;
}
-(void) beforeRequestToken:(NSDictionary *) params
{
    
}
-(void) requestToken:(NSString *) identityProviderUrl completion:(RequestTokenCompletionBlock)block
{
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:_wrapName ,@"wrap_name", _wrapPassword,@"wrap_password", _wrapScope,@"wrap_scope", nil];
    KZHTTPClient * client = [[KZHTTPClient alloc] init];
    [client setBypassSSLValidation:_bypassSSLValidation];
    [client setBasePath:identityProviderUrl];
    [client POST:@"" parameters:params completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>300) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSHTTPURLResponse localizedStringForStatusCode:[urlResponse statusCode]] forKey:NSLocalizedDescriptionKey];
            restError = [NSError errorWithDomain:@"testsIdentityProvider" code:[urlResponse statusCode] userInfo:details];
            block(nil, restError);
        }
        else{
            block([self getAssert:[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]], nil);
        }
    }];
}

- (NSString *) getAssert:(NSString *) text
{
    int start, end;
    end= [text indexOf:@"</Assertion>"] + 12;
    start = [text indexOf:@"<Assertion "];
    NSString * t = [text substringToIndex:end];
    return [t substringFromIndex:start];
}


-(void) afterRequestToken:(NSDictionary *) params
{
    
}
@end
