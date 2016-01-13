#pragma mark - Imports
#import "MTTransportManager.h"

#import "WebSocket_Echo_Client-Swift.h"

#import "MTTransportWebSocket.h"



#pragma mark - Constants



#pragma mark - Private Category
@interface MTTransportManager ()
@property (strong, nonatomic) NSMutableDictionary *transports;
@end



#pragma mark - Implementation
@implementation MTTransportManager
+ (MTTransportManager *)sharedTransportManager
{
    static dispatch_once_t onceToken;
    static MTTransportManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MTTransportManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _transports = [[NSMutableDictionary alloc] init];
    }
    return self;
}



#pragma mark -
- (void)onMessage:(void (^)(id aMessage))aCallback
           forURL:(NSURL *)aURL
          encoder:(MTTransportMessageEncoder)anEncoder
            queue:(dispatch_queue_t)aQueue
{

}

- (void)onFail:(void (^)(NSError *anError))aCallback
        forURL:(NSURL *)aURL
         queue:(dispatch_queue_t)aQueue
{

}

- (void)onStateChange:(void (^)(MTTransportState aState))aCallback
               forURL:(NSURL *)aURL
                queue:(dispatch_queue_t)aQueue
{

}



#pragma mark -
- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    if (transportWebSocket == nil) {
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.name = [NSString stringWithFormat:@"%@", [aURL absoluteString]];
        operationQueue.suspended = YES;

        WebSocket *webSocket = [self webSocketForURL:aURL];

        transportWebSocket = [[MTTransportWebSocket alloc] initWithWebSocket:webSocket operationQueue:operationQueue];
        self.transports[aURL] = transportWebSocket;

        [webSocket connect];
    }

    [transportWebSocket.operationQueue addOperationWithBlock:^{
        [transportWebSocket.webSocket writeString:aMessage];
    }];
}

- (void)closeTransportForURL:(NSURL *)aURL
{

}

- (void)closeAllTransports
{

}

- (WebSocket *)webSocketForURL:(NSURL *)aURL
{
    WebSocket *webSocket = [[WebSocket alloc] initWithUrl:aURL protocols:nil];
    webSocket.onConnect = [self onConnect];
    webSocket.onDisconnect = [self onDisconnect];
    webSocket.onText = [self onText];
    webSocket.onData = [self onData];
    webSocket.onPong = [self onPong];

    return webSocket;
}


#pragma mark - WebSocket Handlers
- (void (^)(NSURL *aURL))onConnect
{
    return ^(NSURL *aURL) {
        MTTransportWebSocket *transportWebSocket = self.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
    };
}

- (void (^)(NSError *error))onDisconnect
{
    return nil;
}

- (void (^)(NSString *text))onText
{
    return ^(NSString *text){
        NSLog(@"%@", text);
    };
}

- (void (^)(NSData *data))onData
{
    return nil;
}

- (void (^)(void))onPong
{
    return nil;
}

@end
