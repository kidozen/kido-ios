#import "KZNotification.h"
#import "KZBaseService+ProtectedMethods.h"

NSString *const kUniqueIdentificationFilename = @"kUniqueIdentificationFilename";

@interface KZNotification ()

@property (nonatomic, copy) NSString * uniqueIdentifier;

@end

@implementation KZNotification

-(id) initWithEndpoint:(NSString *)endpoint andName:(NSString *)name
{
    self = [super initWithEndpoint:endpoint andName:name];
    if (self)
    {
        self.uniqueIdentifier = [self getUniqueIdentification];
    }
    return self;
}


-(void) subscribeDeviceWithToken:(NSString *)deviceToken toChannel:(NSString *) channel completion:(void (^)(KZResponse *))block
{
    NSError * error;
    if ([deviceToken length] == 0 || deviceToken==NULL)
    {
        error = [NSError errorWithDomain:@"com.kidozen.sdk.ios" code:42 userInfo:[NSDictionary dictionaryWithObject:@"Invalid parameter value for 'deviceToken'" forKey:@"Description"]];
    }
    if ([channel length] == 0 || channel==NULL)
    {
        error = [NSError errorWithDomain:@"com.kidozen.sdk.ios" code:42 userInfo:[NSDictionary dictionaryWithObject:@"Invalid parameter value for 'channel'" forKey:@"Description"]];
    }
    if (error) {
        if (block != nil) {
            block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        }
        return;
    }
    
    NSString * path= [NSString stringWithFormat:@"/subscriptions/%@/%@", self.name, channel];
    
    NSDictionary *body = @{@"platform": @"apns",
                           @"subscriptionId": deviceToken,
                           @"deviceId" :self.uniqueIdentifier};
    
    [self addAuthorizationHeader];
    
    [self.client setSendParametersAsJSON:YES];
    [self.client POST:path
           parameters:body
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block
                         response:response
                      urlResponse:urlResponse
                            error:error];
               
           }];
    
}

-(void) pushNotification:(NSDictionary *) notification InChannel:(NSString *) channel completion:(void (^)(KZResponse *))block
{
    NSError * error;
    if ([channel length] == 0 || channel==NULL)
    {
        error = [NSError errorWithDomain:@"com.kidozen.sdk.ios" code:42 userInfo:[NSDictionary dictionaryWithObject:@"Invalid parameter value for 'channel'" forKey:@"Description"]];
    }
    if (error) {
        if (block != nil) {
            block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        }
        return;
    }
    NSString * path= [NSString stringWithFormat:@"/push/%@/%@", self.name, channel];
    [self addAuthorizationHeader];
    [self.client setSendParametersAsJSON:YES];
    
    [self.client POST:path
           parameters:notification
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [self callCallback:block
                         response:response
                      urlResponse:urlResponse
                            error:error];
               
           }];
}

-(void) getSubscriptions:(void (^)(KZResponse *))block
{
    NSString * path= [NSString stringWithFormat:@"/devices/%@/%@", self.uniqueIdentifier, self.name];
    [self addAuthorizationHeader];
    
    [self.client GET:path
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block
                        response:response
                     urlResponse:urlResponse
                           error:error];
              
          }];
}

-(void) getApplicationChannels:(void (^)(KZResponse *))block
{
    NSString * path= [NSString stringWithFormat:@"/channels/%@", self.name];
    [self addAuthorizationHeader];
    
    [self.client GET:path
          parameters:nil
          completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
              
              [self callCallback:block
                        response:response
                     urlResponse:urlResponse
                           error:error];
              
          }];
}

-(void) unSubscribeDeviceUsingToken:(NSString *)deviceToken fromChannel:(NSString *) channel completion:(void (^)(KZResponse *))block
{
    NSError * error;
    if ([deviceToken length] == 0 || deviceToken==NULL)
    {
        error = [NSError errorWithDomain:@"com.kidozen.sdk.ios" code:42 userInfo:[NSDictionary dictionaryWithObject:@"Invalid parameter value for 'deviceToken'" forKey:@"Description"]];
    }
    if ([channel length] == 0 || channel==NULL)
    {
        error = [NSError errorWithDomain:@"com.kidozen.sdk.ios" code:42 userInfo:[NSDictionary dictionaryWithObject:@"Invalid parameter value for 'channel'" forKey:@"Description"]];
    }
    if (error) {
        if (block != nil) {
            block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        }
        return;
    }
    NSString * path= [NSString stringWithFormat:@"/subscriptions/%@/%@/%@", self.name, channel, deviceToken];
    [self addAuthorizationHeader];
    
    [self.client DELETE:path
             parameters:nil
             completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
                 
                 [self callCallback:block
                           response:response
                        urlResponse:urlResponse
                              error:error];
                 
             }];
}


- (NSString *)getUniqueIdentification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *uniqueID = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kUniqueIdentificationFilename];
    
    if (uniqueID == nil) {
        uniqueID = [[NSUUID UUID] UUIDString];
        [userDefaults setValue:uniqueID forKey:kUniqueIdentificationFilename];
        [userDefaults synchronize];
    }
    
    return  uniqueID;
}

@end
