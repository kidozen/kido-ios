#import "KZADFSIdentityProvider.h"
#import "NSString+Utilities.h"

@interface KZADFSIdentityProvider (private)
- (NSString *) requestMessage;
@end

@implementation KZADFSIdentityProvider
@synthesize requestCompletion = _requestCompletion;
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
    _endpoint = identityProviderUrl;
    _requestCompletion = block;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:identityProviderUrl] ];
    NSString *msgLength = [NSString stringWithFormat:@"%u", (unsigned int)[[self requestMessage] length]];
    [req addValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [req addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody: [[self requestMessage] dataUsingEncoding:NSUTF8StringEncoding]];

    [NSURLConnection connectionWithRequest:req delegate:self];
}

- (NSString *) getAssert:(NSString *) text
{
    int start, end;
    end= [text indexOf:@"</Assertion>"] + 12;
    start = [text indexOf:@"<Assertion "];
    NSString * t = [text substringToIndex:end];
    return [t substringFromIndex:start];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _error = error;
    [self throwError];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _httpResponse = (NSHTTPURLResponse *) response;
    if ([_httpResponse statusCode]>299) {
        [self throwError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    _serviceResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    self.requestCompletion([self getAssert:_serviceResponse], nil);
}

-(void) afterRequestToken:(NSDictionary *) params
{
    
}

-(void) throwError
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"KidoZen service returns an invalid response" forKey:NSLocalizedDescriptionKey];
    NSError * restError = [NSError errorWithDomain:@"KZADFSIdentityProvider" code:[_httpResponse statusCode] userInfo:details];
    self.requestCompletion(nil, restError);
}

- (NSString *) requestMessage
{
    NSString * template = @"<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\" xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\"><s:Header><a:Action s:mustUnderstand=\"1\">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action><a:To s:mustUnderstand=\"1\">[To]</a:To><o:Security s:mustUnderstand=\"1\" xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\"><o:UsernameToken u:Id=\"uuid-6a13a244-dac6-42c1-84c5-cbb345b0c4c4-1\"><o:Username>[Username]</o:Username><o:Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">[Password]</o:Password></o:UsernameToken></o:Security></s:Header><s:Body><trust:RequestSecurityToken xmlns:trust=\"http://docs.oasis-open.org/ws-sx/ws-trust/200512\"><wsp:AppliesTo xmlns:wsp=\"http://schemas.xmlsoap.org/ws/2004/09/policy\"><a:EndpointReference><a:Address>[applyTo]</a:Address></a:EndpointReference></wsp:AppliesTo><trust:KeyType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Bearer</trust:KeyType><trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType><trust:TokenType>urn:oasis:names:tc:SAML:2.0:assertion</trust:TokenType></trust:RequestSecurityToken></s:Body></s:Envelope>";
    return [[[[template stringByReplacingOccurrencesOfString:@"[Username]" withString:_wrapName]
                            stringByReplacingOccurrencesOfString:@"[Password]" withString:_wrapPassword]
                                stringByReplacingOccurrencesOfString:@"[To]" withString:_endpoint]
                                    stringByReplacingOccurrencesOfString:@"[applyTo]" withString:_wrapScope];
    
}
@end
