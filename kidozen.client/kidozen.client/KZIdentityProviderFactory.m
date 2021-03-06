#import "KZIdentityProviderFactory.h"
#import "KZWRAPv09IdentityProvider.h"
#import "KZADFSIdentityProvider.h"

@implementation KZIdentityProviderFactory

+(id<KZIdentityProvider>) createProvider:(NSString *) type strictSSL:(BOOL)strictSSL
{
    if ([[type lowercaseString]  isEqualToString:@"wrapv0.9"] ) {
        KZWRAPv09IdentityProvider * kip = [[KZWRAPv09IdentityProvider alloc] init];
        kip.strictSSL = strictSSL;
        return kip;
    }
    else {
        KZADFSIdentityProvider * aip = [[KZADFSIdentityProvider alloc] init];
        aip.strictSSL = strictSSL;
        return aip;
    }
}

@end
