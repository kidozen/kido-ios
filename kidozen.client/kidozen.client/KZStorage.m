#import "KZStorage.h"
#import "KZStorageMetadata.h"
#import "NSDictionary+Mongo.h"
#import "KZBaseService+ProtectedMethods.h"

NSString * const KZStorageErrorDomain = @"KZStorageErrorDomain";
#define ENULLMETADATA       2

@implementation KZStorage

-(void) create:(id)object completion:(void (^)(KZResponse *))block
{
    [self create:object completion:block options:nil];
}

-(void) createPrivate:(id)object completion:(void (^)(KZResponse *))block;
{
    [self create:object completion:block options:@{@"isPrivate" : @"true"}];
}

- (void) create:(id)object completion:(void (^)(KZResponse *))block options:(NSDictionary *)options
{
    if (!object || !self.name) {
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        }
        return;
    }
    
    if ( [(NSObject *)object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *)object;
        object = [d dictionaryWithoutDotsInKeys];
    }
    
    NSString *urlString = [self urlStringWithOptions:options];
    
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client POST:urlString
           parameters:object
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block response:response urlResponse:urlResponse error:error];
               
           }];
    
    
}

- (NSString *)urlStringWithOptions:(NSDictionary *)options
{
    NSMutableString *urlString  = [NSMutableString stringWithString:self.name];
    if ([options count] > 0) {
        [urlString appendString:@"?"];
        
        [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [urlString appendFormat:@"%@=%@&", key, obj];
            
        }];
        return [urlString substringToIndex:[urlString length] - 1];
    } else {
        return urlString;
    }
}

-(void) updateUsingId:(NSString *) objectId object:(id)object
{
    if (!objectId || !object || !self.name) {
        [NSException exceptionWithName:@"KZException" reason:@"Parameter is null" userInfo:nil];
        return;
    }
    if (![object valueForKey:@"_metadata"]) {
        [NSException exceptionWithName:@"KZException" reason:@"You must include the \"_metadata\" information" userInfo:nil];
        return;
    }
    
    [self updateUsingId:objectId object:object completion:NULL];
}

-(void) updateUsingId:(NSString *) objectId object:(id)object completion:(void (^)(KZResponse *))block
{
    if (!object || !self.name) {
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        }
        return;
    }
    NSDictionary * metadata= [object valueForKey:@"_metadata"];
    if (!metadata) {
        NSDictionary *details = [NSDictionary
                                 dictionaryWithObject:@"You must include the \"_metadata\" information"
                                 forKey:NSLocalizedDescriptionKey];
        
        NSError * error = [NSError errorWithDomain:KZStorageErrorDomain code:ENULLMETADATA userInfo:details];
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:error] );
        }
        return;
    }
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client PUT:[NSString stringWithFormat:@"%@/%@",self.name, objectId]
          parameters:[self updateMetadataDates:object]
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
          }];
}

-(void) getUsingId:(NSString *) objectId withBlock:(void (^)(KZResponse *))block;
{
    if (!objectId || !self.name) {
        if (block != nil) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        }
        return;
    }
    
    [self addAuthorizationHeader];
    
    [self.client GET:[NSString stringWithFormat:@"%@/%@",self.name, objectId]
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
              
          }];
}

-(void) deleteUsingId:(NSString *) objectId
{
    if (!objectId || !self.name) {
        [NSException exceptionWithName:@"KZException" reason:@"Parameter is null" userInfo:nil];
        return;
    }
    
    [self deleteUsingId:[NSString stringWithFormat:@"%@/%@",self.name, objectId] withBlock:nil];
}

-(void) deleteUsingId:(NSString *) objectId withBlock:(void (^)(KZResponse *))block
{
    if (!objectId || !self.name ) {
        if (block) {
            block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        }
        return;
    }
    
    [self addAuthorizationHeader];
    
    [self.client DELETE:[NSString stringWithFormat:@"%@/%@",self.name, objectId]
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 [self callCallback:block response:response urlResponse:urlResponse error:error];
             }];
}

-(void) drop
{
    [self drop:nil];
}
-(void) drop:(void (^)(KZResponse *))block
{
    
    [self addAuthorizationHeader];
    
    [self.client DELETE:[NSString stringWithFormat:@"%@",self.name]
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 [self callCallback:block response:response urlResponse:urlResponse error:error];
                 
             }];
}

-(void) all:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    
    [self.client GET:[NSString stringWithFormat:@"%@",self.name]
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
              
          }];
}

-(void) query:(NSString *) query withBlock:(void (^)(KZResponse *))block
{
    if (!query || !self.name) {
        block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        return;
    }
    
    [self addAuthorizationHeader];
    
    [self.client GET:[NSString stringWithFormat:@"%@?query=%@",self.name, query]
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
              
          }];
}

-(void) query:(NSString *) query withOptions:(NSString *) options withBlock:(void (^)(KZResponse *))block
{
    if (!query || !self.name || options) {
        block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        return;
    }
    
    [self addAuthorizationHeader];
    
    [self.client GET:[NSString stringWithFormat:@"/%@?query=%@&options=%@",self.name, query, options]
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
          }];
}

-(void) query:(NSString *) query withOptions:(NSString *) options withFields:(NSString *) fields andBlock:(void (^)(KZResponse *))block
{
    if (!query || !self.name || options || fields) {
        block( [[KZResponse alloc] initWithResponse:nil urlResponse:nil andError:self.createNilReferenceError] );
        return;
    }
    
    [self addAuthorizationHeader];
    
    NSString* urlPath = [NSString stringWithFormat:@"/%@?query=%@&options=%@&fields=%@",self.name, query, options, fields] ;
    [self.client GET:urlPath
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block response:response urlResponse:urlResponse error:error];
              
          }];
}

- (NSArray *) serializeArray:(NSArray *) array
{
    NSMutableArray * returndata = [[NSMutableArray alloc] init];
    for (NSDictionary * d in array) {
        NSMutableDictionary * newvalues = [NSMutableDictionary dictionaryWithDictionary:d];
        NSDictionary * md = [[[[KZStorageMetadata alloc] initWithDictionary:d] deserialize] objectForKey:@"_metadata"];
        [newvalues setValue:md forKey:@"_metadata"];
        [returndata addObject:newvalues];
    }
    return returndata;
}

-(NSDictionary *) updateMetadataDates:(NSDictionary *)object
{
    NSDate * createdOn = [[object objectForKey:@"_metadata"] objectForKey:@"createdOn"];
    NSDate * updatedOn = [[object objectForKey:@"_metadata"] objectForKey:@"updatedOn"];
    NSMutableDictionary *updatedMetadata = [NSMutableDictionary dictionaryWithDictionary:[object objectForKey:@"_metadata"]];
    NSDateFormatter* fmt = [NSDateFormatter new];
    [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.mmm'Z'"];
    
    if ([createdOn isKindOfClass:[NSDate class]]) {
        NSString* date = [fmt stringFromDate:createdOn];
        [updatedMetadata removeObjectForKey:@"createdOn"];
        [updatedMetadata setObject:date forKey:@"createdOn"];
    }
    if ([updatedOn isKindOfClass:[NSDate class]]) {
        NSString* date = [fmt stringFromDate:updatedOn];
        [updatedMetadata removeObjectForKey:@"updatedOn"];
        [updatedMetadata setObject:date forKey:@"updatedOn"];
    }
    
    NSMutableDictionary * updatedObject=[NSMutableDictionary dictionaryWithDictionary:object];
    [updatedObject removeObjectForKey:@"_metadata"];
    [updatedObject setObject:updatedMetadata forKey:@"_metadata"];
    return updatedObject;
}

@end
