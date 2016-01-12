#pragma mark - Imports
#import "MTTransportWebSocket.h"
#import "MTTransportDelegate.h"
#import "MTWebSocket.h"
#import "MTWebSocketDelegate.h"
#import "MTStatistics.h"



#pragma mark - Constants



#pragma mark - Private Category
@interface MTTransportWebSocket () <MTWebSocketDelegate>
@property (strong, nonatomic) MTWebSocket *webSocket;
@end



#pragma mark - Implementation
@implementation MTTransportWebSocket

- (void)dealloc
{
    _webSocket.delegate = nil;
    [_webSocket close];
}

- (MTWebSocket *)webSocket
{
    if (_webSocket == nil) {
        _webSocket = [[MTWebSocket alloc] initWithURL:self.URL];
        _webSocket.delegate = self;
    }
    return _webSocket;
}

- (void)sendContent:(id)aContent
{
    NSError *error = nil;
    NSData *data = nil;
//    if ([aContent conformsToProtocol:@protocol(MTJSONSerializable)]) {
//        data = [NSJSONSerialization dataWithJSONObject:aContent options:NSJSONWritingPrettyPrinted error:&error];
//    }
    NSLog(@"For URL %@, %@, error:%@", self.URL, aContent, error);
//    [[MTStatistics sharedInstance] beginSentBytesUpdate];
//    [[MTStatistics sharedInstance] addBytesSent:data.length];
//    [[MTStatistics sharedInstance] endSentBytesUpdate];
    [self.webSocket sendMessage:aContent];
}

- (void)open
{
    [super open];
    [self.webSocket open];
}

- (void)close
{
    [self.webSocket close];
    [super close];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode
{
    [self.webSocket scheduleInRunLoop:aRunLoop forMode:aMode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode
{
    [self.webSocket removeFromRunLoop:aRunLoop forMode:aMode];
}



#pragma mark - MTWebSocketDelegate
- (void)webSocket:(MTWebSocket *)aWebSocket didFailWithError:(NSError *)anError
{
    NSLog(@"Error for url %@, error: %@", self.URL, anError);
    if ([self.delegate respondsToSelector:@selector(transportDidFail:error:)]) {
        [self.delegate transportDidFail:self error:anError];
    }
}

- (void)webSocketDidClose:(MTWebSocket *)aWebSocket
{
    NSLog(@"Web socket did close for url %@", self.URL);
    self.state = kMTTransportStateClosed;
    if ([self.delegate respondsToSelector:@selector(transportDidClose:)]) {
        [self.delegate transportDidClose:self];
    }
}

- (void)webSocketDidOpen:(MTWebSocket *)aWebSocket
{
    NSLog(@"Web socket did open for url %@", self.URL);
    self.state = kMTTransportStateOpen;
    if ([self.delegate respondsToSelector:@selector(transportDidOpen:)]) {
        [self.delegate transportDidOpen:self];
    }
}

- (void)webSocket:(MTWebSocket *)aWebSocket didReceiveMessage:(NSData *)aMessage
{
    [[MTStatistics sharedInstance] beginReceivedBytesUpdate];
    [[MTStatistics sharedInstance] addBytesReceived:aMessage.length];
    [[MTStatistics sharedInstance] endReceivedBytesUpdate];
    NSError *error = nil;
    id JSONObject = nil;
    if (aMessage != nil) {
        JSONObject = [NSJSONSerialization JSONObjectWithData:aMessage options:0 error:&error];
    }
    NSLog(@"%@, error:%@", JSONObject, error);
    if (error != nil)
    {
        NSLog(@"Data:%@", aMessage);
    }
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *messageContent = (NSDictionary *)JSONObject;
        if ([self.delegate respondsToSelector:@selector(transport:didReceiveMessageContent:)]) {
            [self.delegate transport:self didReceiveMessageContent:messageContent];
        }
    }
}
@end
