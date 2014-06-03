#import "KZLogging.h"

@implementation KZLogging

-(void) write:(id)object withLevel:(LogLevel) level completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    [_client setSendParametersAsJSON:YES];
    [_client POST:[NSString stringWithFormat:@"?level=%d", level] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}

-(void) all:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    [_client GET:@"/" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
    
}
-(void) clear:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    [_client DELETE:@"/" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];

}
-(void) query:(NSString *)query withOptions:(NSString *)options andBlock:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:query,@"query", optopt, @"options", nil];
    [_client GET:@"/" parameters:parameters completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}

@end
