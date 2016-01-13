@import Foundation;



@class WebSocket;



@interface MTTransportWebSocket : NSObject
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) WebSocket *webSocket;

- (instancetype)initWithWebSocket:(WebSocket *)webSocket operationQueue:(NSOperationQueue *)operationQueue;
@end
