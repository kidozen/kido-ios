#import "Query.h"
#import "NSDictionary+JSONCategories.h"
@implementation Query
@synthesize baseDictionary = _baseDictionary;

-(id) initWithName:(NSString *) name andObject:(id) object
{
    self = [super init];
    if (self) {
        _dictionary = [NSMutableDictionary dictionaryWithObject:object forKey:name];
        _baseDictionary = [NSMutableDictionary dictionaryWithDictionary:_dictionary];
    }
    return self;
}
- (NSString *)description
{
    return [_dictionary toJSONString];
}

+(Query *) EqualsTo:(NSString *) name Object:(id)value
{
    return [[Query alloc] initWithName:name andObject:value];
}
+(Query *) NotEquals:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$ne" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];
}
+(Query *) GratherThan:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$gt" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];
}
+(Query *) GratherThanOrEquals:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$gte" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];
}
+(Query *) LessThan:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$lt" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];
}
+(Query *) LessThanOrEquals:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$lte" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];
}
+(Query *) ExistsName:(NSString *) name
{
    NSDictionary * exists = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:@"$exists"];
    return [[Query alloc] initWithName:name andObject:exists];
}
+(Query *) NonExistsName:(NSString *) name
{
    NSDictionary * exists = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:false] forKey:@"$exists"];
    return [[Query alloc] initWithName:name andObject:exists];
}
+(Query *) All:(NSString *)name allValues:(NSArray *) array
{
    NSDictionary * all = [NSDictionary dictionaryWithObject:array forKey:@"$all"];
    return [[Query alloc] initWithName:name andObject:all];
}

+(Query *) ElementMatch:(NSString *)name withQuery:(Query *) query
{
    NSDictionary * elemMatch = [NSDictionary dictionaryWithObject:[query baseDictionary] forKey:@"$elemMatch"];
    return [[Query alloc] initWithName:name andObject:elemMatch];
}
+(Query *) In:(NSString *)name allValues:(NSArray *) array
{
    Query * query = [[Query alloc] initWithName:@"$in" andObject:array];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];   
}
+(Query *) NotIn:(NSString *)name allValues:(NSArray *) array
{
    Query * query = [[Query alloc] initWithName:@"$nin" andObject:array];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];   
}
+(Query *) Matches:(NSString *) name Object:(id)value
{
    Query * query = [[Query alloc] initWithName:@"$regex" andObject:value];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];   
}
+(Query *) Mod:(NSString *)name withModulus:(long)modulus andValue:(long) value
{
    NSArray * array = [NSArray arrayWithObjects:[NSNumber numberWithLong:modulus], [NSNumber numberWithLong:value], nil];
    Query * query = [[Query alloc] initWithName:@"$mod" andObject:array];
    return [[Query alloc] initWithName:name andObject:[query baseDictionary]];   
}
+(Query *) And:(NSArray *) queries
{
    __block NSMutableArray * dicarray = [[NSMutableArray alloc] init];
    [queries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dicarray addObject:[obj baseDictionary]];
    }];
    Query * query = [[Query alloc] initWithName:@"$and" andObject:dicarray];
    return query;
}
+(Query *) Or:(NSArray *) queries
{
    __block NSMutableArray * dicarray = [[NSMutableArray alloc] init];
    [queries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [dicarray addObject:[obj baseDictionary]];
    }];
    Query * query = [[Query alloc] initWithName:@"$or" andObject:dicarray];
    return query;
}


#pragma mark GeoSpacial

+(Query *) Near:(NSString *) name x:(double)x y:(double)y spherical:(bool) spherical
{
    return nil;
}
+(Query *) Near:(NSString *) name x:(double)x y:(double)y maxDistance:(double) maxdistance spherical:(bool) spherical
{
    return nil;
}

@end
