#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@class MTWebSocket;



#pragma mark - Interface
@protocol MTWebSocketDelegate <NSObject>
@optional
- (void)webSocket:(MTWebSocket *)aWebSocket didFailWithError:(NSError *)anError;
- (void)webSocketDidOpen:(MTWebSocket *)aWebSocket;
- (void)webSocketDidClose:(MTWebSocket *)aWebSocket;
- (void)webSocket:(MTWebSocket *)aWebSocket didReceiveMessage:(NSData *)aMessage;

@end
