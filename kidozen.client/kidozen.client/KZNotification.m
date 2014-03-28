#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "KZNotification.h"

@interface KZNotification (private)

- (NSString *)getMacAddress;

@end

@implementation KZNotification

-(id) initWithEndpoint:(NSString *)endpoint andName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.name = name;
        _endpoint = endpoint;
        self.serviceUrl = [NSURL URLWithString:_endpoint] ;
        
        if (!deviceMacAddress) {
            deviceMacAddress = [self getMacAddress];
        }
        
        _client = [[SVHTTPClient alloc] init];
        [_client setBasePath:endpoint];
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
        block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        return;
    }

    NSString * path= [NSString stringWithFormat:@"/subscriptions/%@/%@", self.name, channel];
    NSDictionary * body = [NSDictionary dictionaryWithObjectsAndKeys:@"apns",@"platform", deviceToken, @"subscriptionId", deviceMacAddress, @"deviceId", nil];
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client setSendParametersAsJSON:YES];
    [_client POST:path parameters:body completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
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
        block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        return;
    }
    NSString * path= [NSString stringWithFormat:@"/push/%@/%@", self.name, channel];
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client setSendParametersAsJSON:YES];
    [_client POST:path parameters:notification completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError]);
    }];
}

-(void) getSubscriptions:(void (^)(KZResponse *))block
{
    NSString * path= [NSString stringWithFormat:@"/devices/%@/%@", deviceMacAddress, self.name];
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:path parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}

-(void) getApplicationChannels:(void (^)(KZResponse *))block
{
    NSString * path= [NSString stringWithFormat:@"/channels/%@", self.name];
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client GET:path parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
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
        block([[KZResponse alloc] initWithResponse:Nil urlResponse:nil andError:error]);
        return;
    }
    NSString * path= [NSString stringWithFormat:@"/subscriptions/%@/%@/%@", self.name, channel, deviceToken];
    [_client setHeaders:[NSDictionary dictionaryWithObject:self.kzToken forKey:@"Authorization"]];
    [_client DELETE:path parameters:nil completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSError * restError = nil;
        if ([urlResponse statusCode]>KZHttpErrorStatusCode) {
            restError = error;
        }
        block( [[KZResponse alloc] initWithResponse:response urlResponse:urlResponse andError:restError] );
    }];
}


- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        //DLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    //DLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

@end
