#pragma mark - Imports
#import "MTStatistics.h"



#pragma mark - Constants
NSString *const kMTWillBeginDataTransferNotification = @"MTWillBeginDataTransferNotification";
NSString *const kMTDidEndDataTransferNotification = @"MTDidEndDataTransferNotification";

static const NSTimeInterval kMTDataActivityNotificationFrequency = 1.0;




#pragma mark - Private Category
@interface MTStatistics ()
@property (assign, nonatomic) NSUInteger bytesSent;
@property (assign, nonatomic) NSUInteger bytesReceived;
@property (assign, nonatomic) NSTimeInterval accumulatedResponseLatency;
@property (assign, nonatomic) NSUInteger responsesCount;
@property (assign, nonatomic) NSInteger openUpdatesCount;

@property (strong, atomic) NSDate *lastNotifyBeginDate;
@property (strong, atomic) NSDate *lastNotifyEndDate;
@end



#pragma mark -
#pragma mark Implementation
@implementation MTStatistics
+ (MTStatistics *)sharedInstance
{
    static dispatch_once_t once = 0;
    static MTStatistics *sharedInstance = nil;
    
    dispatch_once(&once, ^{
        sharedInstance = [[MTStatistics alloc] init];
    });
    
    return sharedInstance;
}

- (void)beginSentBytesUpdate
{
    self.openUpdatesCount++;
}

- (void)addBytesSent:(NSUInteger)aBytes
{
    @synchronized (self) {
        _bytesSent += aBytes;
    }
}

- (NSUInteger)bytesSent
{
    NSUInteger result = 0;
    @synchronized (self) {
        result = _bytesSent;
    }
    return result;
}

- (void)endSentBytesUpdate
{
    self.openUpdatesCount--;
}

- (void)beginReceivedBytesUpdate
{
    self.openUpdatesCount++;
}

- (void)addBytesReceived:(NSUInteger)aBytes
{
    @synchronized (self) {
        _bytesReceived += aBytes;
    }
}

- (NSUInteger)bytesReceived
{
    NSUInteger result = 0;
    @synchronized (self) {
        result = _bytesReceived;
    }
    return result;
}

- (void)endReceivedBytesUpdate
{
    self.openUpdatesCount--;
}

- (NSTimeInterval)averageResponseLatency
{
    NSTimeInterval result = 0.0;
    @synchronized (self) {
        if (_responsesCount != 0) {
            result = _accumulatedResponseLatency / (double)_responsesCount;
        }
    }
    return result;
}

- (void)addResponseLatency:(NSTimeInterval)aLatency
{
    @synchronized (self) {
        _accumulatedResponseLatency += aLatency;
        _responsesCount++;
    }
}

- (NSInteger)openUpdatesCount
{
    NSInteger result = 0;
    @synchronized (self) {
        result = self.openUpdatesCount;
    }
    return result;
}

- (void)setOpenUpdatesCount:(NSInteger)aCount
{
    @synchronized (self) {
        if (self.openUpdatesCount != aCount) {
            self.openUpdatesCount = aCount;
            if (self.openUpdatesCount == 1) {
                if ( (self.lastNotifyBeginDate == nil) || ([[NSDate date] timeIntervalSinceDate:self.lastNotifyBeginDate] > kMTDataActivityNotificationFrequency) ){
                    self.lastNotifyBeginDate = [NSDate date];
                    [self performSelectorOnMainThread:@selector(notifyBeginDataTransfer) withObject:nil waitUntilDone:NO];
                }
            } else if (self.openUpdatesCount <= 0) {
                self.openUpdatesCount = 0;
                if ( (self.lastNotifyEndDate == nil) || ([[NSDate date] timeIntervalSinceDate:self.lastNotifyEndDate] > kMTDataActivityNotificationFrequency) ){
                    self.lastNotifyEndDate = [NSDate date];
                    [self performSelectorOnMainThread:@selector(notifyEndDataTransfer) withObject:nil waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)notifyBeginDataTransfer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMTWillBeginDataTransferNotification object:nil];
}

- (void)notifyEndDataTransfer
{
    NSNotification *notiifcation = [NSNotification notificationWithName:kMTDidEndDataTransferNotification object:nil];
    //add delay to avoid flickering
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:notiifcation afterDelay:0.3];
}

@end
