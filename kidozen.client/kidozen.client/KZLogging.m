#import "KZLogging.h"

@implementation KZLogging

- (NSString *)pathForLevel:(LogLevel)level message:(NSString *)message
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"?level=%d", level];
    
    if (message != nil && [message length] > 0) {
        [path appendFormat:@"&message=%@", message];
    }
    return path;
}

-(void) write:(id)object message:(NSString *)message withLevel:(LogLevel)level completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    [_client setSendParametersAsJSON:YES];
    NSString *path = [self pathForLevel:level message:message];
    
    [_client POST:path
       parameters:object
       completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
           NSError * restError = nil;
           if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
               restError = error;
           }
           block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}

-(void) write:(id)object withLevel:(LogLevel) level completion:(void (^)(KZResponse *))block
{
    [self write:object message:nil withLevel:level completion:block];
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
    
    NSDictionary *parameters = @{@"query": query,
                                 @"options": options};
    
    [_client GET:@"/" parameters:parameters completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}

@end
