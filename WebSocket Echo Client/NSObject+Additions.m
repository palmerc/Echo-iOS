#pragma mark - Imports
#import "NSObject+Additions.h"



#pragma mark - Constants



#pragma mark - Private Category



#pragma mark - Implementation
@implementation NSObject (Additions)
- (void)mt_performBlock:(void (^)())aBlock onThread:(NSThread *)aThread waitUntilDone:(BOOL)aWaitFlag
{
    if ([[NSThread currentThread] isEqual:aThread]) {
        aBlock();
    } else {
        [self performSelector:@selector(executeBlockInThread:) onThread:aThread withObject:[aBlock copy] waitUntilDone:aWaitFlag];
    }
}

- (void)executeBlockInThread:(void (^)())aBlock
{
    aBlock();
}

@end


NSComparisonResult mt_safeCompare(id anObj1, id anObj2)
{
    NSComparisonResult result = NSOrderedSame;
    if ( ([anObj1 respondsToSelector:@selector(compare:)]) && (anObj2 != nil) ) {
        result = [anObj1 compare:anObj2];
    } else if ( (anObj1 == nil) && (anObj2 != nil) ) {
        result = NSOrderedAscending;
    } else if ( (anObj1 != nil) && (anObj2 == nil) ) {
        result = NSOrderedDescending;
    }

    return result;
}