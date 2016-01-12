#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@protocol MTTransportObserver;



#pragma mark - Constants



#pragma mark - Interface
@interface MTTransportManager : NSObject
+ (MTTransportManager *)sharedTransportManager;

- (void)addObserver:(id <MTTransportObserver>)anObserver forURL:(NSURL *)aURL;
- (void)removeObserver:(id <MTTransportObserver>)anObserver forURL:(NSURL *)aURL;
- (void)sendContent:(id)aContent forURL:(NSURL *)aURL;

- (void)resetTransportForURL:(NSURL *)aURL;
- (void)resetAllTransports;

- (void)openTransportForURL:(NSURL *)aURL;

- (NSThread *)payloadThread;
@end
