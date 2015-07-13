#import "KZIdentityProvider.h"
#import <SVHTTPClient.h>
/**
 * WRAP V 09 Identity Provider
 *
 * @author KidoZen
 * @version 1.00, April 2013
 */
@interface KZWRAPv09IdentityProvider : NSObject <KZIdentityProvider>
{
    NSString * _wrapName, *_wrapPassword, *_wrapScope;
}
@property (nonatomic, assign) BOOL strictSSL ;
@property (nonatomic, copy) NSString * token;

@end
