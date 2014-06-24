#import "KZUser.h"

NSTimeInterval kTimeOffset = 300;

@interface KZUser()

@property (nonatomic, copy) NSString *kzToken;
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
        self.kzToken = [token decodeHTMLEntities:token];
        [self parse];
    }
    return self;
}

-(void)parse
{
    NSArray * parts = [self.kzToken componentsSeparatedByString:@"&"];
    for (NSString *obj in parts) {
        NSArray *components = [obj componentsSeparatedByString:@"="];
        NSString *key = [[[components objectAtIndex:0] componentsSeparatedByString:@"/"] lastObject];
        [_claims setObject:[[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]
                    forKey:key];
        
        if ([key isEqualToString:@"role"]) {
            _roles = [[[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]componentsSeparatedByString:@","];
        }
        
        if ([_claims objectForKey:KEY_EXPIRES]) {
            NSDate *lastDate = [[NSDate alloc] initWithTimeIntervalSince1970:[[_claims objectForKey:KEY_EXPIRES] intValue]];
            NSDate *todaysDate = [NSDate date];
            NSTimeInterval lastDiff = [lastDate timeIntervalSinceNow];
            NSTimeInterval todaysDiff = [todaysDate timeIntervalSinceNow];
            _expiresOn = round(lastDiff - todaysDiff - kTimeOffset);
            
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
