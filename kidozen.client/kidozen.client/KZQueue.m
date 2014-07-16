#import "KZQueue.h"
#import "KZBaseService+ProtectedMethods.h"


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
    __weak KZQueue *safeMe = self;
    
    [_client POST:[NSString stringWithFormat:@"/%@",self.name] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:restError];
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
    __weak KZQueue *safeMe = self;
    
    [_client DELETE:[NSString stringWithFormat:@"/%@/next",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:restError];
        }
    }];
    return;
}
@end
