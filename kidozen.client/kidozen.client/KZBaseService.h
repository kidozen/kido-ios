#import <Foundation/Foundation.h>
#import "SVHTTPClient.h"
#import "KZResponse.h" 
#import "KZIdentityProvider.h"
#import "KZUser.h"

extern NSInteger const KZHttpErrorStatusCode;

@class KZTokenController;

@interface KZBaseService : NSObject


- (id)initWithEndpoint:(NSString *)endpoint andName:(NSString *)name;
- (void)addAuthorizationHeader;

// This property will be in charge of managing all token related things.
@property (nonatomic, strong) KZTokenController *tokenController;

// In case you need the http client that the service uses to create the requests
@property (nonatomic, readonly) SVHTTPClient *client;

@property (nonatomic, copy, readonly) NSString *endpoint;
@property (nonatomic, copy, readonly) NSString * name;

@property (nonatomic, readonly) NSURL * serviceUrl;
@property (atomic, assign) BOOL isAuthenticated;
@property (atomic, strong) KZUser * KidoZenUser;

@property (nonatomic, assign) BOOL strictSSL;

@end
