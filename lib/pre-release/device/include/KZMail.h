/**
 * Mail service interface
 *
 * @author kidozen
 * @version 1.00, April 2013
 */

#import "KZBaseService.h"

@interface KZMail : KZBaseService

/**
 * @param mail a NSDictionary with the information of the Email message to send.
 * It needs to have the following required keys
 *         "to"
 *         "from"
 *         "htmlBody"
 *         "textBody"
 * @param block The callback with the result of the service call
 */
-(void) send:(NSDictionary *)email completion:(void (^)(KZResponse *))block;

/**
 * @param mail a NSDictionary with the information of the Email message to send.
 * It needs to have the following required keys
 *         "to"
 *         "from"
 *         "htmlBody"
 *         "textBody"
 * @param attachments is a dictionary where the key is the filename and the value 
 * is an instance of NSData to send.
 * @param block The callback with the result of the service call
 */
-(void) send:(NSDictionary *)email attachments:(NSDictionary *)attachments completion:(void (^)(KZResponse *))block;

@end
