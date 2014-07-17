
#import "KZBaseService.h"

/* 
 * This class has methods to interact with your Kidozen's services.
 * For more information http://docs.kidozen.com/enterprise-apis-services/
 */
@interface KZService : KZBaseService

-(void) invokeMethod:(NSString *)method
            withData:(id)data
          completion:(void (^)(KZResponse *))block;

-(void) invokeMethod:(NSString *)method
            withData:(id)data
             timeout:(int)timeout
          completion:(void (^)(KZResponse *))block;


-(void) invokeMethodWithAuth:(NSString *) method
                    withData:(id)data
                  completion:(void (^)(KZResponse *))block;

-(void) invokeMethodWithAuth:(NSString *)method
                    withData:(id)data
                     timeout:(int)timeout
                  completion:(void (^)(KZResponse *))block;

@end
