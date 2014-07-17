#import "KZMail.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZMail

-(void) send:(NSDictionary *)email completion:(void (^)(KZResponse *))block
{
    
    [self send:email attachments:nil completion:block];
}

-(void) send:(NSDictionary *)email attachments:(NSDictionary*)attachments completion:(void (^)(KZResponse *))block
{
    
    __weak KZMail *safeMe = self;
    
    if (attachments != nil) {
        self.client.sendParametersAsJSON = NO;

#ifdef DEBUG
        [attachments enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSAssert([obj isKindOfClass:[NSData class]], @"Not an NSData class");
        }];
#endif
        
        [self sendEmailToPath:@"/attachments"
                   parameters:attachments
                   completion:^(KZResponse *kzResponse) {
                       
                       if ([kzResponse.urlResponse statusCode]>KZHttpErrorStatusCode)
                       {
                           block(kzResponse);
                       }
                       else
                       {
                           self.client.sendParametersAsJSON = YES;
                           NSMutableDictionary *mailDictionary = [NSMutableDictionary dictionaryWithDictionary:email];
                           mailDictionary[@"attachments"] = kzResponse.response;
                           [safeMe sendEmailToPath:@"" parameters:mailDictionary completion:block];
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
    [self addAuthorizationHeader];
    __weak KZMail *safeMe = self;
    
    [self.client POST:path parameters:parameters completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
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
