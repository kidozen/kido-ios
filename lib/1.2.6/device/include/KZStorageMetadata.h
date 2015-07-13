#import <Foundation/Foundation.h>

@interface KZStorageMetadata : NSObject
{
    NSMutableDictionary * _serialized;
    NSMutableDictionary * _deserialized;
    NSMutableDictionary * _metadata;
}


@property (nonatomic, copy) NSString * _id;
@property (nonatomic, copy) NSString * createdBy;
@property (nonatomic, strong) NSDate * createdOn;
@property (nonatomic) BOOL isPrivate;
@property (nonatomic) NSInteger sync;
@property (nonatomic, copy) NSString * updatedBy;
@property (nonatomic, strong) NSDate * updatedOn;

@property (nonatomic, copy) NSString * createdOnAsString;
@property (nonatomic, copy) NSString * updatedOnAsString;

- (id) initWithDictionary:(NSDictionary *) dictionary;
- (NSDictionary *) serialize;
- (NSDictionary *) deserialize;
@end
