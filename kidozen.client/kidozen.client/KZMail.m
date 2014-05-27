#import "KZMail.h"

@implementation KZMail

-(void) send:(NSDictionary *)email completion:(void (^)(KZResponse *))block
{
    
    [self send:email attachments:nil completion:block];
}

-(void) send:(NSDictionary *)email attachments:(NSDictionary*)attachments completion:(void (^)(KZResponse *))block
{
    
    __weak KZMail *safeMe = self;
    
    if (attachments != nil) {
        _client.sendParametersAsJSON = NO;
        
        [self sendEmailToPath:@"/attachments"
                   parameters:attachments
                   completion:^(KZResponse *response) {
                       
                       if ([response.urlResponse statusCode]>KZHttpErrorStatusCode)
                       {
                           block(response);
                       }
                       else
                       {
                           NSMutableDictionary *mailDictionary = [NSMutableDictionary dictionaryWithDictionary:email];
                           mailDictionary[@"attachments"] = response;
                           [safeMe sendEmailToPath:@"" parameters:email completion:block];
                       }
                   }];
        
    }
    else
    {
        [self sendEmailToPath:@"" parameters:email completion:block];
    }
}

- (void) sendEmailToPath:(NSString *)path
              parameters:(NSDictionary *)parameters
              completion:(void (^)(KZResponse *r))block
{
    [_client setHeaders:@{@"Authorization": self.kzToken,
                          @"Accept" :@"application/json"}];
    
    [_client POST:path parameters:parameters completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];

    
}

@end
