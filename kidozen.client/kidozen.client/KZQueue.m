#import "KZQueue.h"


@implementation KZQueue

-(void) enqueue:(id)object
{
    if (!object || !self.name) {
        [NSException exceptionWithName:@"KZException" reason:@"The parameter is null" userInfo:nil];
    }
    [self addAuthorizationHeader];
    [_client setSendParametersAsJSON:YES];
    [_client POST:[NSString stringWithFormat:@"/%@",self.name] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
    }];
}


-(void) enqueue:(id)object completion:(void (^)(KZResponse *))block
{
    if (!object || !self.name) {
        block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        return;
    }
    [self addAuthorizationHeader];
    [_client POST:[NSString stringWithFormat:@"/%@",self.name] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
        }
    }];
}

-(void) dequeue:(void (^)(KZResponse *))block
{
    if (!self.name) {
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        }
        return;
    }
    [self addAuthorizationHeader];
    [_client DELETE:[NSString stringWithFormat:@"/%@/next",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
        }
    }];
    return;
}
@end
