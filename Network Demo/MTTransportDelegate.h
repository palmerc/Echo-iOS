#pragma mark - Imports



#pragma mark - Predeclarations
@class MTTransportBase;



#pragma mark - Interface
@protocol MTTransportDelegate <NSObject>
@optional
- (void)transport:(MTTransportBase *)aTransport didReceiveMessageContent:(NSDictionary *)aMessageContent;
- (void)transportDidClose:(MTTransportBase *)aTransport;
- (void)transportDidOpen:(MTTransportBase *)aTransport;
- (void)transportDidFail:(MTTransportBase *)aTransport error:(NSError *)anError;
@end
