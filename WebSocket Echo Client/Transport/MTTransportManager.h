#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@protocol MTTransportObserver;



#pragma mark - Constants
typedef NS_ENUM (NSInteger, MTTransportMesageEncoder)
{
    kMTTransportMesageEncoderBinary = 0,
    kMTTransportMesageEncoderJSON
};

typedef NS_ENUM (NSInteger, MTTransportState)
{
    MTTransportStateUnknown = 0,
    kMTTransportStateConnect,
    kMTTransportStateClose
};


#pragma mark - Interface
@interface MTTransportManager : NSObject
+ (MTTransportManager *)sharedTransportManager;

- (void)onTextMessage:(void (^)(id aMessage))aCallback
               forURL:(NSURL *)aURL
              encoder:(MTTransportMesageEncoder)anEncoder
                queue:(dispatch_queue_t)aQueue;

- (void)onFail:(void (^)(NSError *anError))aCallback
        forURL:(NSURL *)aURL
         queue:(dispatch_queue_t)aQueue;

- (void)onStateChange:(void (^)(MTTransportState aState))aCallback
               forURL:(NSURL *)aURL
                queue:(dispatch_queue_t)aQueue;

- (void)resetTransportForURL:(NSURL *)aURL;
- (void)resetAllTransports;

- (void)openTransportForURL:(NSURL *)aURL;

- (NSThread *)payloadThread;
@end