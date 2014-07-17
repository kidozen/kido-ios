#import "KZPubSubChannel.h"
#import "KZBaseService+ProtectedMethods.h"

@implementation KZPubSubChannel
@synthesize wsEndpoint = _wsEndpoint;
@synthesize channelName = _channelName;
@synthesize webSocketCompletionEventBlock = _webSocketCompletionEventBlock;

-(id)initWithEndpoint:(NSString *)endpoint wsEndpoint:(NSString *) wsEndpoint andName:(NSString *)name
{
    self = [super initWithEndpoint:endpoint andName:nil];
    if (self) {
        _channelName = name;
        _wsEndpoint = wsEndpoint;
    }
    return self;
}


-(void) publish:(id)object completion:(void (^)(KZResponse *))block
{
    [self addAuthorizationHeader];
    if ([object isKindOfClass:[NSString class]]) {
        [self.client setSendParametersAsJSON:YES];
    }
    [self.client setSendParametersAsJSON:YES];
    __weak KZPubSubChannel *safeMe = self;
    
    [self.client POST:[NSString stringWithFormat:@"/%@", self.channelName]
           parameters:object
           completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
               
               [safeMe callCallback:block
                           response:response
                        urlResponse:urlResponse
                              error:error];
               
           }];
}

-(void) subscribe:(WebSocketEventBlock) completionEventBlock
{
    self.webSocketCompletionEventBlock = completionEventBlock;
    NSMutableURLRequest * nsurl = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_wsEndpoint]];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:nsurl];
    [_webSocket setDelegate:self];
    [_webSocket open];
    return;
}

-(void) unsubscribe:(WebSocketEventBlock) completionEventBlock
{
    if (_webSocket) {
        [_webSocket close];
    }
    return;
}


#pragma mark - SRWebSocketDelegate

-(void) webSocketDidOpen:(SRWebSocket *)webSocket
{
    //DLog(@"webSocketDidOpen");
    NSString * connect = [NSString stringWithFormat:@"bindToChannel::{\"application\":\"local\",\"channel\":\"%@\"}",_channelName];
    [_webSocket send:connect];
}

-(void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(NSString *)message
{
    //DLog(@"didReceiveMessage: %@", message);
    NSError * error = nil;
    message = [message substringFromIndex:[message indexOf:@"::"] + 2];
    NSDictionary *jsonMessage =
    [NSJSONSerialization JSONObjectWithData: [message dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &error];
    if (_webSocketCompletionEventBlock) {
        if (error) {
            _webSocketCompletionEventBlock(error);
        }
        else
            _webSocketCompletionEventBlock(jsonMessage);
    }
}
-(void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    //DLog(@"didFailWithError: %@", error);
    if (_webSocketCompletionEventBlock) {
        _webSocketCompletionEventBlock(error);
    }
}
-(void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    //DLog(@"Close code: %u",code);
    NSDictionary *message = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:code],@"code", reason,@"reason",[NSNumber numberWithBool:wasClean],@"wasClean", nil];
    if (_webSocketCompletionEventBlock) {
        _webSocketCompletionEventBlock(message);
    }
}
@end
