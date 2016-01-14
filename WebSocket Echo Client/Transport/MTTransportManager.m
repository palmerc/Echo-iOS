#pragma mark - Imports
#import "MTTransportManager.h"

#import "MTTransportDelegate.h"
#import "WebSocket_Echo_Client-Swift.h"



#pragma mark - Constants



#pragma mark - Private Category
@interface MTTransportManager ()
@property (strong, nonatomic) NSMutableDictionary<NSURL *, MTTransportWebSocket *> *transports;
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
- (void)addTransportDelegate:(id<MTTransportDelegate>)aDelegate forURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = [self transportWebSocketForURL:aURL];
    [transportWebSocket addTransportDelegate:aDelegate];
}

- (void)removeTransportDelegate:(id<MTTransportDelegate>)aDelegate forURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = [self transportWebSocketForURL:aURL];
    [transportWebSocket removeTransportDelegate:aDelegate];
    if ([transportWebSocket.delegates count] == 0) {
        [transportWebSocket.webSocket disconnect];
        [self.transports removeObjectForKey:aURL];
    }
}



#pragma mark -
- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = [self transportWebSocketForURL:aURL];
    if (!transportWebSocket.webSocket.isConnected) {
        [transportWebSocket.webSocket connect];
    }

    static uint8_t counter = 0;
    [transportWebSocket.operationQueue addOperationWithBlock:^{
        if ([aMessage length] > 0) {
            [transportWebSocket.webSocket writeString:aMessage];
        } else {
            NSUInteger lengthOfBytes = sizeof(counter);
            NSData *data = [NSData dataWithBytes:&counter length:lengthOfBytes];
            [transportWebSocket.webSocket writePing:data];
            counter++;
        }
    }];
}

- (void)closeTransportForURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = [self transportWebSocketForURL:aURL];
    if (transportWebSocket.webSocket.isConnected) {
        [transportWebSocket.webSocket disconnect];
    }
}

- (void)closeAllTransports
{
    for (NSURL *transportURL in self.transports) {
        [self closeTransportForURL:transportURL];
    }
}

- (MTTransportWebSocket *)transportWebSocketForURL:(NSURL *)aURL
{
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    if (transportWebSocket == nil) {
        transportWebSocket = [[MTTransportWebSocket alloc] init];
        self.transports[aURL] = transportWebSocket;
    }

    if (transportWebSocket.operationQueue == nil) {
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.name = [NSString stringWithFormat:@"%@", [aURL absoluteString]];
        operationQueue.suspended = YES;
        transportWebSocket.operationQueue = operationQueue;
    }

    if (transportWebSocket.webSocket == nil) {
        WebSocket *webSocket = [self webSocketForURL:aURL];
        transportWebSocket.webSocket = webSocket;
    }

    return transportWebSocket;
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
    __weak __typeof__(self) weakSelf = self;
    return ^(NSURL *aURL) {
        MTTransportWebSocket *transportWebSocket = weakSelf.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        for (id<MTTransportDelegate> delegate in transportWebSocket.delegates) {
            if ([delegate respondsToSelector:@selector(transportStateChanged:forURL:)]) {
                [delegate transportStateChanged:TransportStateConnect forURL:aURL];
            }
        }
    };
}

- (void (^)(NSURL *aURL, NSError *error))onDisconnect
{
    __weak __typeof__(self) weakSelf = self;
    return ^(NSURL *aURL, NSError *error){
        MTTransportWebSocket *transportWebSocket = weakSelf.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        for (id<MTTransportDelegate> delegate in transportWebSocket.delegates) {
            if ([delegate respondsToSelector:@selector(transportStateChanged:forURL:)]) {
                [delegate transportStateChanged:TransportStateClose forURL:aURL];
            }
        }
    };
}

- (void (^)(NSURL *aURL, NSString *text))onText
{
    __weak __typeof__(self) weakSelf = self;
    return ^(NSURL *aURL, NSString *text){
        MTTransportWebSocket *transportWebSocket = weakSelf.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        for (id<MTTransportDelegate> delegate in transportWebSocket.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:forURL:)]) {
                [delegate didReceiveMessage:text forURL:aURL];
            }
        }
    };
}

- (void (^)(NSURL *aURL, NSData *data))onData
{
    __weak __typeof__(self) weakSelf = self;
    return ^(NSURL *aURL, NSData *data){
        MTTransportWebSocket *transportWebSocket = weakSelf.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        for (id<MTTransportDelegate> delegate in transportWebSocket.delegates) {
            if ([delegate respondsToSelector:@selector(didReceiveMessage:forURL:)]) {
                [delegate didReceiveMessage:data forURL:aURL];
            }
        }
    };
}

- (void (^)(NSURL *aURL))onPong
{
    __weak __typeof__(self) weakSelf = self;
    return ^(NSURL *aURL){
        MTTransportWebSocket *transportWebSocket = weakSelf.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        for (id<MTTransportDelegate> delegate in transportWebSocket.delegates) {
            NSString *pong = NSLocalizedString(@"PONG!", @"PONG!");
            if ([delegate respondsToSelector:@selector(didReceiveMessage:forURL:)]) {
                [delegate didReceiveMessage:pong forURL:aURL];
            }
        }
    };
}

@end
