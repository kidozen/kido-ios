#import "KZMail.h"

@implementation KZMail

-(void) send:(id)email completion:(void (^)(KZResponse *))block
{
    [_client POST:@"" parameters:email completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}
@end
