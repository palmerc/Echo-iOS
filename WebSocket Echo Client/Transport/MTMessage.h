@import Foundation;



@interface MTMessage : NSObject
@property (strong, nonatomic) id message;
@property (strong, nonatomic) NSURL *URL;

- (instancetype)initWithMessage:(id)aMessage forURL:(NSURL *)aURL;
@end
