#import "KZQueue.h"
#import "KZBaseService+ProtectedMethods.h"


@implementation KZQueue

-(void) enqueue:(id)object
{
    [self enqueue:object completion:nil];
}


-(void) enqueue:(id)object completion:(void (^)(KZResponse *))block
{
    if (!object || !self.name) {
        if (block)
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        return;
    }
    
    [self addAuthorizationHeader];
    
    [self.client POST:[NSString stringWithFormat:@"/%@",self.name]
           parameters:object
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block
                         response:response
                      urlResponse:urlResponse
                            error:error];
               
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
    
    [self.client DELETE:[NSString stringWithFormat:@"/%@/next",self.name]
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 [self callCallback:block
                           response:response
                        urlResponse:urlResponse
                              error:error];
                 
             }];
    return;
}

@end
