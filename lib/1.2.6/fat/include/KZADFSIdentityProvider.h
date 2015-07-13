/**
 * Active Directory Federation Services Identity Provider
 *
 * @author kidozen
 * @version 1.00, April 2013
 *
 */
#import <Foundation/Foundation.h>
#import <SVHTTPClient.h>
#import "KZIdentityProvider.h"

@interface KZADFSIdentityProvider : NSObject <KZIdentityProvider, NSURLConnectionDelegate>
{
    NSString * _wrapName, *_wrapPassword, *_wrapScope, *_endpoint;
    NSString * _serviceResponse;
    dispatch_semaphore_t semaphore;
    NSError  * _error;
    NSHTTPURLResponse * _httpResponse;
}
@property (nonatomic, copy) NSString * token;
@property (nonatomic, strong) RequestTokenCompletionBlock requestCompletion;
@property (nonatomic, assign) BOOL strictSSL;
@end
