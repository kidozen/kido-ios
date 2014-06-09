#import <Foundation/Foundation.h>

@protocol KZAuthentication <NSObject>

-(void) authenticateUser:(NSString *) user withProvider:(NSString *) provider andPassword:(NSString *) password;
-(void) authenticateUser:(NSString *) user withProvider:(NSString *) provider andPassword:(NSString *) password completion:(void (^)(id))block;

/**
 * Starts a passive authentication flow.
 *
 * @param tenantMarketPlace The url of the KidoZen marketplace
 * @param applicationName The application name
 * @param strictSSL Whether we want SSL to be bypassed or not,  only use in development
 */
- (void)startPassiveAuthenticationWithProvider:(NSString *)provider completion:(void (^)(id))block;

//custom provider
-(void) registerProviderWithClassName:(NSString *) className andProviderKey:(NSString *) providerKey;
-(void) registerProviderWithInstance:(id) instance andProviderKey:(NSString *) providerKey;

@end
