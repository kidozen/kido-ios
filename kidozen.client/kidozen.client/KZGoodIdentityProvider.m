//
//  KZGoodIdentityProvider.m
//  kidozen.client
//
//  Created by Nicolas Miyasato on 3/2/15.
//  Copyright (c) 2015 KidoZen. All rights reserved.
//

#import "KZGoodIdentityProvider.h"
#import "KZGood.h"

NSString *const kChallengeKey = @"challenge";

@interface KZGoodIdentityProvider()

@property (nonatomic, strong) KZGood *good;
@property (nonatomic, copy) NSString *challenge;

@end

@implementation KZGoodIdentityProvider

-(void) initializeWithUserName:(NSString *)user
                      password:(NSString *)password
                      andScope:(NSString *)scope
{
    // Must implement due to non-optional protocol
    // Nothing to do here.
}


-(void) requestToken:(NSString *) identityProviderUrl completion:(RequestTokenCompletionBlock)block
{
    
    self.good = [[KZGood alloc] initWithWindow:[[UIApplication sharedApplication].delegate window]];
    
    [self.good getGTToken:self.challenge
                   server:identityProviderUrl
                  success:^(NSString *token) {
                      block(token, nil);
                  }
                    error:^(NSError *error) {
                        block(nil, error);
                    }];
}

-(void) configure:(id) configuration
{
    NSDictionary *d = configuration;
    if ([d objectForKey:kChallengeKey] == nil) {
        NSLog(@"You need to have a challenge key in your parameters");
        @throw [NSException exceptionWithName:@"Good Tech Failure init."
                                       reason:@"You need to have a challenge key in your parameters"
                                     userInfo:@{@"message" : @"You need to have a challenge key in your parameters"}];
        
    }
    
    self.challenge = [configuration objectForKey:@"challenge"];
    
}


-(void) beforeRequestToken:(NSDictionary *) params
{
    // Must implement due to non-optional protocol
    // Nothing to do here.

}

-(void) afterRequestToken:(NSDictionary *) params
{
    // Must implement due to non-optional protocol
    // Nothing to do here.

}
@end
