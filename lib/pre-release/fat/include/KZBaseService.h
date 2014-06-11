#import <Foundation/Foundation.h>
#import "SVHTTPClient.h"
#import "KZResponse.h" 
#import "KZIdentityProvider.h"
#import "KZUser.h"

extern NSInteger const KZHttpErrorStatusCode;

@class KZTokenController;

@interface KZBaseService : NSObject
{
    NSString * _endpoint;
    SVHTTPClient * _client;
    NSURL * baseUrl;
    BOOL _bypassSSL;

}

// This property will be in charge of managing all token related things.
@property (nonatomic, strong) KZTokenController *tokenControler;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSURL * serviceUrl;
@property (atomic) BOOL isAuthenticated;
@property (atomic, strong) KZUser * KidoZenUser;


-(id) initWithEndpoint:(NSString *) endpoint andName:(NSString *) name;
-(NSError *) createNilReferenceError;
-(void) setBypassSSL:(BOOL)bypass;
-(BOOL) bypassSSL;

- (void)addAuthorizationHeader;

@end
