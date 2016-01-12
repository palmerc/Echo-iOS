#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
@protocol MTTransportDelegate;



#pragma mark - Constants
enum
{
    kMTTransportStateClosed = 0,
    kMTTransportStateOpen
};
typedef NSUInteger MTTransportState;



#pragma mark - Interface
@interface MTTransportBase : NSObject
@property (weak, nonatomic) id<MTTransportDelegate> delegate;
@property (assign, atomic) MTTransportState state;

- (id)initWithURL:(NSURL *)aURL;

- (NSURL *)URL;
- (void)sendContent:(id)aContent;
- (void)close;
- (void)open;

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode;
@end
