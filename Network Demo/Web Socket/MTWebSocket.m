#pragma mark - Imports
#import "MTWebSocket.h"

#import <Socket_IO_Client_Swift/Socket_IO_Client_Swift-Swift.h>

#import "MTWebSocketDelegate.h"



#pragma mark - Constants
NSString *const kMTWebSocketErrorDomain = @"MTWebSocketErrorDomain";
NSString *const kMTWebSocketErrorUserInfoKey = @"UserInfo";
enum {
    kMTWebSocketStateSendHandShake = 0,
    kMTWebSocketStateWaitHandShake,
    kMTWebSocketStateRunning,
    kMTWebSocketStateSendClosingHandShake,
    kMTWebSocketStateWaitClosingHandShake,
    kMTWebSocketStateIsClosed
};



#pragma mark - Private Category
@interface MTWebSocket ()
@property (strong, nonatomic) WebSocket *websocket;

@property (strong, nonatomic, readwrite) NSURL *URL;

@property (strong, nonatomic) NSMutableArray *outgoingMessages;
@property (strong, nonatomic) NSMutableArray *incomingMessages;
@property (assign, nonatomic) NSInteger state;

@end



#pragma mark - Implementation
@implementation MTWebSocket
- (id)initWithURL:(NSURL *)aURL isSecure:(BOOL)aSecureFlag {
    self = [super init];
    if (self != nil) {
        _URL = aURL;
	}
    return self;
}

- (id)initWithURL:(NSURL *)aURL {
    BOOL isSecure = [[aURL scheme] isEqualToString:@"wss"];
    return [self initWithURL:aURL isSecure:isSecure];
}

- (void)open {
    self.state = kMTWebSocketStateSendHandShake;
    __weak __typeof__(self) weakSelf = self;
    self.websocket.onConnect = ^{
        __typeof__(self) strongSelf = weakSelf;
        strongSelf.state = kMTWebSocketStateRunning;
        [strongSelf.delegate webSocketDidOpen:weakSelf];
    };
    self.websocket.onText = ^void (NSString *text) {
        [weakSelf receivedText:text];
    };
    self.websocket.onData = ^void (NSData *data) {
        [weakSelf receivedData:data];
    };
    [self.websocket connect];
}

- (void)close {
    self.state = kMTWebSocketStateSendClosingHandShake;
//    if ( ([self.writeStream hasSpaceAvailable]) && (self.writeStream.streamStatus != NSStreamStatusError) )  {
//        [self doWrite];
//    }
}

- (void)sendMessage:(id)aMessage {
    @synchronized (self) {
        [self.outgoingMessages addObject:aMessage];
    }
    if ( (self.state == kMTWebSocketStateRunning) && ([self.websocket isConnected]) ) {
        [self sendMessages];
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode {
//    [self.readStream scheduleInRunLoop:aRunLoop forMode:aMode];
//    [self.writeStream scheduleInRunLoop:aRunLoop forMode:aMode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode {
//    [self.readStream removeFromRunLoop:aRunLoop forMode:aMode];
//    [self.writeStream removeFromRunLoop:aRunLoop forMode:aMode];
}



#pragma mark - Private
- (void)sendMessages {
    @synchronized (self) {
        NSArray *messages = nil;
//        if (self.state == kMTWebSocketStateSendHandShake) {
//            self.state = kMTWebSocketStateWaitHandShake;
//            fragmentsToSend = @[[MTWebSocketFragment fragmentOpeningHandShakeForURL:self.URL]];
//        } else if (self.state == kMTWebSocketStateSendClosingHandShake) {
//            self.state = kMTWebSocketStateWaitClosingHandShake;
//            [self.outgoingFragments addObject:[MTWebSocketFragment fragmentWithControlCode:kMTMessageControlCodeClose payload:nil]];
//            fragmentsToSend = [self.outgoingFragments copy];
//            [self.outgoingFragments removeAllObjects];
//        } else if (self.state == kMTWebSocketStateRunning) {
//        }

        messages = [self.outgoingMessages copy];
        [self.outgoingMessages removeAllObjects];

        for (id message in messages) {
            if ([message isKindOfClass:[NSString class]]) {
                NSString *messageString = (NSString *)message;
                [self.websocket writeString:messageString];
            } else if ([message isKindOfClass:[NSData class]]) {
                NSData *messageData = (NSData *)message;
                [self.websocket writeData:messageData];
            } else {
                NSLog(@"Unsupported message type - %@", NSStringFromClass([message class]));
            }
        }
    }
}

- (void)receivedText:(NSString *)text
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, text);
}

- (void)receivedData:(NSData *)data
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, data);
}

- (NSMutableArray *)outgoingMessages
{
    if (_outgoingMessages == nil) {
        self.outgoingMessages = [[NSMutableArray alloc] init];
    }
    return _outgoingMessages;
}

- (NSMutableArray *)incomingMessages
{
    if (_incomingMessages == nil) {
        self.incomingMessages = [[NSMutableArray alloc] init];
    }
    return _incomingMessages;
}

- (WebSocket *)websocket
{
    if (_websocket == nil) {
        self.websocket = [[WebSocket alloc] initWithUrl:self.URL protocols:nil];
    }
    return _websocket;
}

- (void)invalidateStreams {
//    self.readStream.delegate = nil;
//    [self.readStream close];
//    
//    self.writeStream.delegate = nil;
//    [self.writeStream close];
}
@end
