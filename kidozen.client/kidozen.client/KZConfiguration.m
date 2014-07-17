#import "KZConfiguration.h"
#import "NSDictionary+Mongo.h"
#import "KZBaseService+ProtectedMethods.h"


@implementation KZConfiguration

-(void) save:(id)object completion:(void (^)(KZResponse *))block
{
    if ( [(NSObject *)object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *)object;
        object = [d dictionaryWithoutDotsInKeys];
    }

    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    __weak KZConfiguration *safeMe = self;
    [self.client POST:[NSString stringWithFormat:@"/%@",self.name] parameters:object completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
        }
    }];
}

-(void) get:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZConfiguration *safeMe = self;
    
    [self.client GET:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
        }
    }];
}

-(void) remove
{
    [self addAuthorizationHeader];
    [self.client DELETE:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
    }];
}
-(void) remove:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZConfiguration *safeMe = self;
    
    [self.client DELETE:[NSString stringWithFormat:@"/%@",self.name] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
        }
    }];
}

-(void) all:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZConfiguration *safeMe = self;
    
    [self.client GET:@"/" parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:error];
        }
    }];
}

@end
