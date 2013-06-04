
#import "KZService.h"

@implementation KZService

-(void) invokeMethod:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block
{
    if (!method || !self.name) {
        [NSException exceptionWithName:@"KZException" reason:@"The parameter is null" userInfo:nil];
        }
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
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
