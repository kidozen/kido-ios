#import "KZIdentityProviderFactory.h"
#import "KZWRAPv09IdentityProvider.h"
#import "KZADFSIdentityProvider.h"

@implementation KZIdentityProviderFactory

+(id<KZIdentityProvider>) createProvider:(NSString *) type bypassSSL:(BOOL) bypassSSL
{
    if ([[type lowercaseString]  isEqualToString:@"wrapv0.9"] ) {
        KZWRAPv09IdentityProvider * kip = [[KZWRAPv09IdentityProvider alloc] init];
        [kip setBypassSSLValidation:bypassSSL];
        return kip;
    }
    else {
        KZADFSIdentityProvider * aip = [[KZADFSIdentityProvider alloc] init];
        [aip setBypassSSLValidation:bypassSSL];
        return aip;
    }
}

@end
