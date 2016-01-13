#pragma mark - Imports
#import "MTTransportManager.h"

#import "WebSocket_Echo_Client-Swift.h"



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
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    if (transportWebSocket == nil) {
        transportWebSocket = [[MTTransportWebSocket alloc] init];
        self.transports[aURL] = transportWebSocket;
    }

    transportWebSocket.onMessage = aCallback;
    transportWebSocket.encoder = anEncoder;
    transportWebSocket.onMessageQueue = aQueue;
}

- (void)onFail:(void (^)(NSError *anError))aCallback
        forURL:(NSURL *)aURL
         queue:(dispatch_queue_t)aQueue
{
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    if (transportWebSocket == nil) {
        transportWebSocket = [[MTTransportWebSocket alloc] init];
        self.transports[aURL] = transportWebSocket;
    }

    transportWebSocket.onFail = aCallback;
    transportWebSocket.onFailQueue = aQueue;
}

- (void)onStateChange:(void (^)(MTTransportState aState))aCallback
               forURL:(NSURL *)aURL
                queue:(dispatch_queue_t)aQueue
{
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    if (transportWebSocket == nil) {
        transportWebSocket = [[MTTransportWebSocket alloc] init];
        self.transports[aURL] = transportWebSocket;
    }

    transportWebSocket.onStateChange = aCallback;
    transportWebSocket.onStateChangeQueue = aQueue;
}



#pragma mark -
- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL
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

        [webSocket connect];
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
    MTTransportWebSocket *transportWebSocket = self.transports[aURL];
    [transportWebSocket.webSocket disconnect];
}

- (void)closeAllTransports
{
    for (NSURL *transportURL in self.transports) {
        [self closeTransportForURL:transportURL];
    }
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
        dispatch_async(transportWebSocket.onStateChangeQueue, ^{
            if (transportWebSocket.onStateChange) {
                transportWebSocket.onStateChange(TransportStateConnect);
            }
        });
    };
}

- (void (^)(NSURL *aURL, NSError *error))onDisconnect
{
    return ^(NSURL *aURL, NSError *error){
        MTTransportWebSocket *transportWebSocket = self.transports[aURL];
        transportWebSocket.operationQueue.suspended = NO;
        dispatch_async(transportWebSocket.onFailQueue, ^{
            if (transportWebSocket.onStateChange) {
                transportWebSocket.onStateChange(TransportStateClose);
            }
        });
    };
}

- (void (^)(NSURL *aURL, NSString *text))onText
{
    return ^(NSURL *aURL, NSString *text){
        MTTransportWebSocket *transportWebSocket = self.transports[aURL];
        dispatch_async(transportWebSocket.onMessageQueue, ^{
            if (transportWebSocket.onMessage) {
                transportWebSocket.onMessage(text);
            }
        });
    };
}

- (void (^)(NSURL *aURL, NSData *data))onData
{
    return ^(NSURL *aURL, NSData *data){
        MTTransportWebSocket *transportWebSocket = self.transports[aURL];
        dispatch_async(transportWebSocket.onMessageQueue, ^{
            if (transportWebSocket.onMessage) {
                transportWebSocket.onMessage(data);
            }
        });
    };
}

- (void (^)(NSURL *aURL))onPong
{
    return ^(NSURL *aURL){
        MTTransportWebSocket *transportWebSocket = self.transports[aURL];
        dispatch_async(transportWebSocket.onMessageQueue, ^{
            if (transportWebSocket.onMessage) {
                NSString *pong = NSLocalizedString(@"PONG!", @"PONG!");
                transportWebSocket.onMessage(pong);
            }
        });
    };
}

@end
