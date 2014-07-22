#import "KZConfiguration.h"
#import "NSDictionary+Mongo.h"
#import "KZBaseService+ProtectedMethods.h"


@implementation KZConfiguration

-(void) save:(id)object completion:(void (^)(KZResponse *))block
{
    if ( [object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *)object;
        object = [d dictionaryWithoutDotsInKeys];
    }
    
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client POST:[NSString stringWithFormat:@"/%@",self.name]
           parameters:object
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               [self  callCallback:block
                          response:response
                       urlResponse:urlResponse
                             error:error];
           }];
}

-(void) get:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    [self.client GET:[NSString stringWithFormat:@"/%@",self.name]
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              [self callCallback:block
                        response:response
                     urlResponse:urlResponse
                           error:error];
          }];
}

-(void) remove
{
    [self addAuthorizationHeader];
    [self.client DELETE:[NSString stringWithFormat:@"/%@",self.name]
             parameters:nil
             completion:nil];
}
-(void) remove:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    [self.client DELETE:[NSString stringWithFormat:@"/%@",self.name]
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 [self callCallback:block
                           response:response
                        urlResponse:urlResponse
                              error:error];
                 
             }];
}

-(void) all:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    [self.client GET:@"/"
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block
                        response:response
                     urlResponse:urlResponse
                           error:error];
              
          }];
}

@end
