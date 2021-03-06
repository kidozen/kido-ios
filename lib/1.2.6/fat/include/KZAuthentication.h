#import <Foundation/Foundation.h>

@protocol KZAuthentication <NSObject>

-(void) authenticateUser:(NSString *) user withProvider:(NSString *) provider andPassword:(NSString *) password;
-(void) authenticateUser:(NSString *) user withProvider:(NSString *) provider andPassword:(NSString *) password completion:(void (^)(id))block;

/**
 * Starts a passive authentication flow.
 */
- (void)startPassiveAuthenticationWithCompletion:(void (^)(id response))block;

//custom provider
-(void) registerProviderWithClassName:(NSString *) className andProviderKey:(NSString *) providerKey;
-(void) registerProviderWithInstance:(id) instance andProviderKey:(NSString *) providerKey;

@end
