#import "KZUser.h"

@interface KZUser()
- (void) parse;
@end

@implementation KZUser

NSString *const KEY_EXPIRES = @"ExpiresOn";

@synthesize claims = _claims;
@synthesize roles = _roles;
@synthesize expiresOn = _expiresOn;
@synthesize user = _user;
@synthesize pass = _pass;

-(id) initWithToken:(NSString *) token
{
    self = [super init];
    if (self)
    {
        _roles = [[NSArray alloc] init];
        _claims = [[NSMutableDictionary alloc] init];
        _kzToken = [[token decodeHTMLEntities:token] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self parse];
    }
    return self;
}

-(void)parse
{
    NSArray * parts = [_kzToken componentsSeparatedByString:@"&"];

    NSEnumerator *e = [parts objectEnumerator];
    id obj;
    while (obj = [e nextObject]) {
        NSArray * part = [obj componentsSeparatedByString:@"="];
        NSString * key =[[[part objectAtIndex:0]  componentsSeparatedByString:@"/"] lastObject];
        [_claims setObject:[part objectAtIndex:1] forKey:key];
        
        if ([key isEqualToString:@"role"]) {
            _roles = [[part objectAtIndex:1] componentsSeparatedByString:@","];
        }
        if ([_claims objectForKey:KEY_EXPIRES]) {
            NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[[_claims objectForKey:KEY_EXPIRES] intValue]];
            NSDate *todaysDate = [NSDate date];
            NSTimeInterval lastDiff = [lastDate timeIntervalSinceNow];
            NSTimeInterval todaysDiff = [todaysDate timeIntervalSinceNow];
            _expiresOn = round(lastDiff - todaysDiff);

        }
    }
}

-(BOOL*) isInRole:(NSString *) role
{
    BOOL __block *ret = NO;
    [_roles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqualToString:role]) {
            * ret = YES;
        }
    }];
    return ret;
}

@end
