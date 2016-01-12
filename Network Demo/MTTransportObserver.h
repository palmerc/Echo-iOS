#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations



#pragma mark - Interface
@protocol MTTransportObserver <NSObject>
@optional
- (void)transportForURL:(NSURL *)aURL didReceiveMessageContent:(NSDictionary *)aMessageContent;
- (void)transportDidConnectForURL:(NSURL *)aURL;
- (void)transportDidCloseForURL:(NSURL *)aURL;
- (void)transportDidFailForURL:(NSURL *)aURL error:(NSError *)anError;
@end
