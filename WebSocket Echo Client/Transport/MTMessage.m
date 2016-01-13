#import "MTMessage.h"



@implementation MTMessage
- (instancetype)initWithMessage:(id)aMessage forURL:(NSURL *)aURL
{
    self = [super init];
    if (self != nil) {
        _message = aMessage;
        _URL = aURL;
    }

    return self;
}
@end
