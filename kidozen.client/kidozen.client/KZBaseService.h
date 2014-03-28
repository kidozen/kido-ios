#import <Foundation/Foundation.h>
#import "SVHTTPClient.h"
#import "KZResponse.h" 
#import "KZIdentityProvider.h"
#import "KZUser.h"

extern NSInteger const KZHttpErrorStatusCode;

@interface KZBaseService : NSObject
{
    NSString * _endpoint;
    SVHTTPClient * _client;
    NSURL * baseUrl;
    BOOL _bypassSSL;

}
@property (atomic, strong) NSString * kzToken;
@property (atomic, strong) NSString * ipToken;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSURL * serviceUrl;
@property (atomic) BOOL isAuthenticated;
@property (atomic, strong) KZUser * KidoZenUser;


-(id) initWithEndpoint:(NSString *) endpoint andName:(NSString *) name;
-(NSError *) createNilReferenceError;
-(void) setBypassSSL:(BOOL)bypass;
-(BOOL) bypassSSL;
@end
