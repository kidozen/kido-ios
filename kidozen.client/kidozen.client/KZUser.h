#import <Foundation/Foundation.h>
#import "NSString+Utilities.h"
/**
 * The kidozen user identity
 *
 * @author KidoZen
 * @version 1.00, April 2013
 *
 */
@interface KZUser : NSObject

-(id) initWithToken:(NSString *) token;

/**
 * Checks if the user belongs to the role
 * @param role
 * @return
 */
-(BOOL*) isInRole:(NSString *) role;

/**
 * The claims of this user
 */
@property (nonatomic, strong) NSMutableDictionary * claims;
/**
 * The Roles of this user
 */
@property (nonatomic, strong) NSArray * roles;
/**
 * The expiration in seconds
 */
@property (nonatomic) int expiresOn;

@property (nonatomic, copy) NSString * user;
@property (nonatomic, copy) NSString * pass;

@property (nonatomic, copy) NSString *provider;

@end
