#import "KZConfiguration.h"

@implementation KZConfiguration

-(void) save:(id)object completion:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client setSendParametersAsJSON:YES];
    [_client POST:[NSString stringWithFormat:@"/%@",self.name] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
}

-(void) get:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
}

-(void) remove
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client DELETE:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
    }];
}
-(void) remove:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client DELETE:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
}

-(void) all:(void (^)(KZResponse *))block
{
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:@"/" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:error] );
    }];
}

@end
