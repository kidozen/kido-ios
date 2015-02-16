#import "KZUser.h"

NSTimeInterval kTimeOffset = 10;

@interface KZUser()

@property (nonatomic, copy) NSString *kzToken;
@property (nonatomic, copy, readwrite) NSString *userId;

- (void) parse;
@end

@implementation KZUser

NSString *const KEY_EXPIRES = @"ExpiresOn";

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
            NSTimeInterval futureTimestamp = [self.claims[KEY_EXPIRES] integerValue];
            NSTimeInterval rightNowTimestamp = [[NSDate date] timeIntervalSince1970];
            
            self.expiresOn = round(futureTimestamp - rightNowTimestamp - kTimeOffset);
        }
        
        if ([key hasSuffix:@"userid"]) {
            self.userId = [components objectAtIndex:1];            
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
