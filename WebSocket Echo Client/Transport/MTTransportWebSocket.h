#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@class WebSocket;



#pragma mark - Constants
typedef NS_ENUM (NSInteger, MTTransportMessageEncoder)
{
    TransportMessageEncoderBinary = 0,
    TransportMessageEncoderUTF8
};

typedef NS_ENUM (NSInteger, MTTransportState)
{
    TransportStateUnknown = 0,
    TransportStateConnect,
    TransportStateClose
};



@interface MTTransportWebSocket : NSObject
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) WebSocket *webSocket;

@property (copy, nonatomic) void (^onMessage)(id aMessage);
@property (copy, nonatomic) void (^onPong)();
@property (copy, nonatomic) void (^onFail)(NSError *error);
@property (copy, nonatomic) void (^onStateChange)(MTTransportState aState);

@property (assign, nonatomic) dispatch_queue_t onMessageQueue;
@property (assign, nonatomic) dispatch_queue_t onPongQueue;
@property (assign, nonatomic) dispatch_queue_t onFailQueue;
@property (assign, nonatomic) dispatch_queue_t onStateChangeQueue;

@property (assign, nonatomic) MTTransportMessageEncoder encoder;
@end
