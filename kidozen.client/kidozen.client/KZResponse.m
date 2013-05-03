#import "KZResponse.h"

@implementation KZResponse
@synthesize response = _response;
@synthesize urlResponse = _urlResponse;
@synthesize error = _error;
@synthesize application = _application;

-(id) initWithResponse:(id) response urlResponse:(NSHTTPURLResponse *) urlresponse andError:(NSError *) error
{
    self = [super init];
    if (self) {
        _response = response;
        _urlResponse = urlresponse;
        _error = error;
    }
    return self;
}
@end
