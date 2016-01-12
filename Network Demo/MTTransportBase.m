#pragma mark - Imports
#import "MTTransportBase.h"



#pragma mark - Constants



#pragma mark - Private Category
@interface MTTransportBase () 
@property (strong, nonatomic) NSURL *URL;
@end



#pragma mark - Implementation
@implementation MTTransportBase
- (id)initWithURL:(NSURL *)aURL
{
    self = [super init];
    if (self != nil) {
        self.URL = aURL;
    }

    return self;
}

- (void)sendContent:(NSDictionary *)aContent
{
}

- (void)open
{
}

- (void)close
{
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode
{
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)aMode
{
}
@end
