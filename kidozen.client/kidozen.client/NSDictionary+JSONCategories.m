#import "NSDictionary+JSONCategories.h"

@implementation NSDictionary (JSONCategories)

+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

-(NSData*) toJSONData
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;    
}

-(NSString*) toJSONString
{
    NSString * result = [[NSString alloc] initWithData:[self toJSONData] encoding:NSUTF8StringEncoding];    
    return result;    
}

@end
