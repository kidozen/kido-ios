#import <Foundation/Foundation.h>
#import "KZService.h"

@interface KZFileManager : KZService

-(void) uploadFileStream:(NSStream *)content inPath:(NSString *) path completion:(void (^)(KZResponse *))block;
-(void) downloadFromPath:(NSString *)path completion:(void (^)(KZResponse *))block;
-(void) deleteFromPath:(NSString *) path  completion:(void (^)(KZResponse *))block;
-(void) browsePath:(NSString *) path  completion:(void (^)(KZResponse *))block;

@end
