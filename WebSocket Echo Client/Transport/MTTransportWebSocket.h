#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@class WebSocket;
@protocol MTTransportDelegate;



@interface MTTransportWebSocket : NSObject
@property (strong, nonatomic) NSOperationQueue *operationQueue;
@property (strong, nonatomic) WebSocket *webSocket;
@property (strong, nonatomic, readonly) NSArray<id<MTTransportDelegate>> *delegates;

- (void)addTransportDelegate:(id<MTTransportDelegate>)delegate;
- (void)removeTransportDelegate:(id<MTTransportDelegate>)delegate;

@end
