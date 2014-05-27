#import "KZMail.h"

@implementation KZMail

-(void) send:(NSDictionary *)email completion:(void (^)(KZResponse *))block
{
    
    [self send:email attachments:nil completion:block];
}

-(void) send:(NSDictionary *)email attachments:(NSDictionary*)attachments completion:(void (^)(KZResponse *))block
{
    if (attachments != nil) {
        _client.sendParametersAsJSON = NO;
        [_client setHeaders:@{@"Authorization": self.kzToken,
                              @"Accept" :@"application/json"}];
        
        [_client POST:@"/attachments" parameters:attachments completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSError * restError = nil;
            if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
                restError = error;
            }

            _client.sendParametersAsJSON = YES;

            [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
            NSMutableDictionary *mailDictionary = [NSMutableDictionary dictionaryWithDictionary:email];
            mailDictionary[@"attachments"] = response;
            [_client POST:@"" parameters:mailDictionary completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                NSError * restError = nil;
                if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
                    restError = error;
                }
                block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
            }];
            
        }];
        
    } else {
        [_client setHeaders:@{@"Authorization": self.kzToken,
                              @"Accept" :@"application/json"}];
        [_client POST:@"" parameters:email completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSError * restError = nil;
            if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
                restError = error;
            }
            block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
        }];
    }
}

@end
