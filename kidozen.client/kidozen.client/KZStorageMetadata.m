#import "KZStorageMetadata.h"

#define ISO_TIMEZONE_UTC_FORMAT @"Z"
#define ISO_TIMEZONE_OFFSET_FORMAT @"%+02d%02d"

@interface KZStorageMetadata ()
- (NSString *) getStringFromDate:(NSDate *) date;
- (NSDate *) getDateFromString:(NSString *) dateAsString;
@end

@implementation KZStorageMetadata

- (id) init
{
    self = [super init];
    if (self) {
        _metadata = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"", @"createdBy",
                     [NSDate date],@"createdOn",
                     @1, @"isPrivate",
                     @0, @"sync",
                     @"", @"updatedBy",
                     [NSDate date], @"updatedOn",
                     nil];
        _serialized = [[NSMutableDictionary alloc] initWithObjectsAndKeys:0,@"_id",@"_metadata",_metadata, nil];
    }
    return self;
}

- (NSMutableDictionary *)serializeMetadata:(NSDictionary *)dictionary
{
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [dictionary objectForKey:@"_id"],@"_id",
            
            [[NSMutableDictionary alloc] initWithObjectsAndKeys:
             [[dictionary objectForKey:@"_metadata"] objectForKey:@"createdBy"], @"createdBy",
             _createdOnAsString, @"createdOn",
             [NSString stringWithFormat:@"%d",_isPrivate], @"isPrivate",
             [NSString stringWithFormat:@"%@",@(_sync)],@"sync",
             [[dictionary objectForKey:@"_metadata"] objectForKey:@"updatedBy"], @"updatedBy",
             _updatedOnAsString, @"updatedOn",nil],@"_metadata",
            nil];
}

- (NSMutableDictionary *)derializeMetadata:(NSDictionary *)dictionary
{
    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            [dictionary objectForKey:@"_id"],@"_id",
            
            [[NSMutableDictionary alloc] initWithObjectsAndKeys:
             [[dictionary objectForKey:@"_metadata"] objectForKey:@"createdBy"], @"createdBy",
             _createdOn, @"createdOn",
             [NSNumber numberWithBool:_isPrivate], @"isPrivate",
             [NSNumber numberWithInteger:_sync],@"sync",
             [[dictionary objectForKey:@"_metadata"] objectForKey:@"updatedBy"], @"updatedBy",
             _updatedOn, @"updatedOn",nil],@"_metadata",
            nil];
}

- (id) initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if (self) {
        id d1 = [[dictionary objectForKey:@"_metadata"] objectForKey:@"createdOn"];
        if ([d1 isKindOfClass:[NSString class]])
        {
            _createdOn = [self getDateFromString:[[dictionary objectForKey:@"_metadata"] objectForKey:@"createdOn"]];
        }
        else
        {
            _createdOn = d1;
        }
        id d2 = [[dictionary objectForKey:@"_metadata"] objectForKey:@"updatedOn"];
        if ([d2 isKindOfClass:[NSString class]]) {
            _updatedOn = [self getDateFromString:[[dictionary objectForKey:@"_metadata"] objectForKey:@"updatedOn"]];
        }
        else
        {
            _updatedOn = d2;
        }
        _createdOnAsString = [self getStringFromDate:_createdOn];
        _updatedOnAsString = [self getStringFromDate:_updatedOn];
        _isPrivate = [[[dictionary objectForKey:@"_metadata"] objectForKey:@"isPrivate"] intValue];
        _sync =  [[[dictionary objectForKey:@"_metadata"] objectForKey:@"sync"] intValue];
        
        _serialized = [self serializeMetadata:dictionary];
        _deserialized = [self derializeMetadata:dictionary];
    }
    return self;
}


- (NSDate *) getDateFromString:(NSString *) dateAsString
{
    [NSTimeZone resetSystemTimeZone];
    NSLocale *enUSPOSIXLocale;
    NSDateFormatter *sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
    enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
    [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    if( [dateAsString characterAtIndex:[dateAsString length]-1] == 'Z' ) {
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    else {
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSDate *theDate = nil;
    NSError *error = nil;
    
    if (![sRFC3339DateFormatter getObjectValue:&theDate forString:dateAsString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateAsString, error);
    }
    
    NSDate *date = [sRFC3339DateFormatter dateFromString:dateAsString];
    return date;
}


- (NSString *) getStringFromDate:(NSDate *) date
{
    [NSTimeZone resetSystemTimeZone];
    NSLocale *enUSPOSIXLocale;
    NSDateFormatter *sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
    enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
    [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return [sRFC3339DateFormatter stringFromDate:date];
}

- (NSDictionary *) serialize
{
    return _serialized;
}
- (NSDictionary *) deserialize
{
    return _deserialized;
}

@end
