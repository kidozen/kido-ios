#import "KZSMSSender.h"
#import "NSString+Utilities.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZSMSSender

-(void) send:(NSString *)message completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    NSString * nr = [[[[[self.name stringByReplacingOccurrencesOfString:@"(" withString:@""]
                                    stringByReplacingOccurrencesOfString:@")" withString:@""]
                                        stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                            stringByReplacingOccurrencesOfString:@" " withString:@"" ]
                     encodeUsingEncoding:NSUTF8StringEncoding];
    
    NSString * url = [NSString stringWithFormat:@"?to=%@&message=%@", nr, [message encodeUsingEncoding:NSUTF8StringEncoding] ];


    __weak KZSMSSender *safeMe = self;
    
    [self.client POST:url parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:restError];
        }
    }];

}
-(void) getStatus:(NSString *)messageId completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    __weak KZSMSSender *safeMe = self;

    [self.client GET:[NSString stringWithFormat:@"/%@",messageId] parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        if (block != nil) {
            [safeMe callCallback:block response:response urlResponse:urlResponse error:restError];
        }
    }];
}

@end
