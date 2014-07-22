#import "KZService.h"
#import "NSData+SRB64Additions.h"
#import "KZTokenController.h"
#import "NSData+Conversion.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZService

-(void) invokeMethod:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block
{
    [self invokeMethodCore:method withData:data andHeaders:nil completion:block];
}

-(void) invokeMethod:(NSString *)method withData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block
{
    [self invokeMethodCore:method
                  withData:data
                andHeaders:@{@"timeout": [NSString stringWithFormat:@"%d", timeout]}
                completion:block];
}

-(void) invokeMethodWithAuth:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block
{
    NSString *authHeader = [self authHeaderString];
    
    NSDictionary *headers = @{@"x-kidozen-actas": authHeader};
    
    [self invokeMethodCore:method withData:data andHeaders:headers completion:block];
}

-(void) invokeMethodWithAuth:(NSString *)method withData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block
{
    NSString *authHeader = [self authHeaderString];
    NSDictionary *headers = @{@"x-kidozen-actas": authHeader,
                              @"timeout": [NSString stringWithFormat:@"%d", timeout]};
    
    [self invokeMethodCore:method withData:data andHeaders:headers completion:block];
}

-(void) invokeMethodCore:(NSString *) method withData:(id) data andHeaders:(NSDictionary *) headers completion:(void (^)(KZResponse *)) block
{
    if (!method || !self.name) {
        block ( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError]);
        return;
    }
    
    NSMutableDictionary *headersToUse = [NSMutableDictionary dictionaryWithObject:self.tokenController.kzToken
                                                                           forKey:@"Authorization"];
    
    
    if  (headers) {
        [headersToUse addEntriesFromDictionary:headers];
    }
    
    [self.client setHeaders:headersToUse];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client POST:[NSString stringWithFormat:@"invoke/%@",method]
           parameters:data
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block
                         response:response
                      urlResponse:urlResponse
                            error:error];
               
           }];
}

- (NSString *)authHeaderString
{
    NSData *plainData = [self.tokenController.ipToken dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedToken = [plainData SR_stringByBase64Encoding];
    
    return [NSString stringWithFormat:@"Bearer %@", encodedToken];
    
}

@end
