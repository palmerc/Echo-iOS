#pragma mark - Imports
@import Foundation;

#import "MTTransportWebSocket.h"



#pragma mark - Predeclarations
@protocol MTTransportDelegate;



#pragma mark - Constants



#pragma mark - Interface
@interface MTTransportManager : NSObject
+ (MTTransportManager *)sharedTransportManager;

- (void)addTransportDelegate:(id<MTTransportDelegate>)aDelegate forURL:(NSURL *)aURL;
- (void)removeTransportDelegate:(id<MTTransportDelegate>)aDelegate forURL:(NSURL *)aURL;

- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL;

- (void)closeTransportForURL:(NSURL *)aURL;
- (void)closeAllTransports;
@end