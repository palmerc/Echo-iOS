#pragma mark - Imports
#import "MTTransportWebSocket.h"

#import "MTTransportDelegate.h"



#pragma mark - Private Category
@interface MTTransportWebSocket ()
@property (strong, nonatomic, readwrite) NSArray<id<MTTransportDelegate>> *delegates;
@end



#pragma mark - Implementation
@implementation MTTransportWebSocket
- (void)addTransportDelegate:(id<MTTransportDelegate>)delegate
{
    if (self.delegates) {
        NSMutableArray *mutableDelegates = [self.delegates mutableCopy];
        [mutableDelegates addObject:delegate];
        self.delegates = [mutableDelegates copy];
    } else {
        self.delegates = @[delegate];
    }
}

- (void)removeTransportDelegate:(id<MTTransportDelegate>)delegate
{
    if (self.delegates) {
        NSMutableArray *mutableDelegates = [self.delegates mutableCopy];
        [mutableDelegates removeObject:delegate];
        if ([mutableDelegates count] > 0) {
            self.delegates = [mutableDelegates copy];
        } else {
            self.delegates = nil;
        }
    }
}

@end
