#pragma mark - Imports
@import Foundation;



#pragma mark - Predeclarations



#pragma mark - Constants



#pragma mark - Interface
@interface NSObject (Additions)
- (void)mt_performBlock:(void (^)())aBlock onThread:(NSThread *)aThread waitUntilDone:(BOOL)aWaitFlag;
@end


extern NSComparisonResult mt_safeCompare(id anObj1, id anObj2);