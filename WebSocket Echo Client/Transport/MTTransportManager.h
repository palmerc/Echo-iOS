#pragma mark - Imports
@import Foundation;

#import "MTTransportWebSocket.h"



#pragma mark - Predeclarations
@protocol MTTransportObserver;



#pragma mark - Constants



#pragma mark - Interface
@interface MTTransportManager : NSObject
+ (MTTransportManager *)sharedTransportManager;

- (void)onMessage:(void (^)(id aMessage))aCallback
           forURL:(NSURL *)aURL
          encoder:(MTTransportMessageEncoder)anEncoder
            queue:(dispatch_queue_t)aQueue;

- (void)onFail:(void (^)(NSError *anError))aCallback
        forURL:(NSURL *)aURL
         queue:(dispatch_queue_t)aQueue;

- (void)onStateChange:(void (^)(MTTransportState aState))aCallback
               forURL:(NSURL *)aURL
                queue:(dispatch_queue_t)aQueue;

- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL;

- (void)closeTransportForURL:(NSURL *)aURL;
- (void)closeAllTransports;
@end