
#import "KZBaseService.h"

@interface KZService : KZBaseService

-(void) invokeMethod:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block;
-(void) invokeMethod:(NSString *)method withData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block;

-(void) invokeMethodWithAuth:(NSString *) method withData:(id)data completion:(void (^)(KZResponse *))block;
-(void) invokeMethodWithAuth:(NSString *)method withData:(id)data timeout:(int)timeout completion:(void (^)(KZResponse *))block;

@end
