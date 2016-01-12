#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations
extern NSString *const kMTWillBeginDataTransferNotification;
extern NSString *const kMTDidEndDataTransferNotification;



#pragma mark - Constants



#pragma mark - Interface
@interface MTStatistics : NSObject
+ (MTStatistics *)sharedInstance;

- (void)beginSentBytesUpdate;
- (void)addBytesSent:(NSUInteger)aBytes;
- (NSUInteger)bytesSent;
- (void)endSentBytesUpdate;

- (void)beginReceivedBytesUpdate;
- (void)addBytesReceived:(NSUInteger)aBytes;
- (NSUInteger)bytesReceived;
- (void)endReceivedBytesUpdate;

- (NSTimeInterval)averageResponseLatency;
- (void)addResponseLatency:(NSTimeInterval)aLatency;
@end
