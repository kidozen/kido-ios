#import "KZService.h"
#import "NSData+SRB64Additions.h"

@implementation KZService

-(void) invokeMethod:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block
{
    [self invokeMethodCore:method withData:data andHeaders:nil completion:block];
}

-(void) invokeMethodWithAuth:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block
{
    NSData *plainData = [self.ipToken dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedToken = [plainData SR_stringByBase64Encoding];
    
    NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", encodedToken];
    
    NSDictionary *headers = [NSDictionary dictionaryWithObject:authHeader forKey:@"x-kidozen-actas"];
    
    [self invokeMethodCore:method withData:data andHeaders:headers completion:block];
}

-(void) invokeMethodCore:(NSString *) method withData:(id) data andHeaders:(NSDictionary *) headers completion:(void (^)(KZResponse *)) block
{
    if (!method || !self.name) {
        [NSException exceptionWithName:@"KZException" reason:@"The parameter is null" userInfo:nil];
    }
    
    NSMutableDictionary *headersToUse = [NSMutableDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"];
    
    if  (headers) {
        [headersToUse addEntriesFromDictionary:headers];
    }
    
    [_client setHeaders:headersToUse];
    [_client setSendParametersAsJSON:YES];
    
    [_client POST:[NSString stringWithFormat:@"invoke/%@",method] parameters:data completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}


@end
