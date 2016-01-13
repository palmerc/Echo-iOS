#import "MTTransportWebSocket.h"



@implementation MTTransportWebSocket
- (instancetype)initWithWebSocket:(WebSocket *)webSocket operationQueue:(NSOperationQueue *)operationQueue
{
    self = [super init];
    if (self != nil) {
        _webSocket = webSocket;
        _operationQueue = operationQueue;
    }

    return self;
}
@end
