@import Foundation;



#pragma mark - Constants
typedef NS_ENUM (NSInteger, MTTransportState)
{
    TransportStateUnknown = 0,
    TransportStateConnect,
    TransportStateClose
};



@protocol MTTransportDelegate <NSObject>
@optional
- (void)didReceiveMessage:(id)aMessage forURL:(NSURL *)aURL;
- (void)transportFailed:(NSError *)anError forURL:(NSURL *)aURL;
- (void)transportStateChanged:(MTTransportState)aState forURL:(NSURL *)aURL;
@end
