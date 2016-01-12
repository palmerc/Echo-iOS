#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@protocol MTWebSocketDelegate;



#pragma mark - Constants
enum {
    kMTWebSocketErrorConnectionFailed = 1,
    kMTWebSocketErrorHandshakeFailed = 2
};

extern NSString *const kMTWebSocketErrorDomain;
extern NSString *const kMTWebSocketErrorUserInfoKey;



#pragma mark - Interface
@interface MTWebSocket : NSObject
@property (strong, atomic, readonly) NSURL *URL;
@property (weak, nonatomic) id<MTWebSocketDelegate> delegate;

- (id)initWithURL:(NSURL *)aURL;

- (void)open;
- (void)close;
- (void)sendMessage:(NSData *)aMessage;

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode;

@end
