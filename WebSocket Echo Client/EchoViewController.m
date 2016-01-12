#import "EchoViewController.h"
#import "MTTransportObserver.h"
#import "MTTransportManager.h"



static NSString *const kEchoWebsocketTestServerURL = @"ws://echo.websocket.org/";



@interface EchoViewController () <MTTransportObserver>
@property (weak, nonatomic) MTTransportManager *transportManager;
@property (strong, nonatomic) NSURL *URL;
@property (assign, nonatomic, getter=isConnected) BOOL connect;
@property (strong, nonatomic) NSString *message;

@end



@implementation EchoViewController

- (void)dealloc
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    MTTransportManager *transportManager = [MTTransportManager sharedTransportManager];
    self.transportManager = transportManager;
    self.URL = [NSURL URLWithString:kEchoWebsocketTestServerURL];
}

- (void)setConnect:(BOOL)connect
{
    _connect = connect;
}



#pragma mark - IBAction
- (IBAction)didPressRepeatButton:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)didPressSendButton:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self.transportManager sendContent:self.message forURL:self.URL];
}

- (IBAction)editingDidBeginEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)editingChangedEchoTextField:(id)sender
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, sender);

    UITextField *textField = sender;
    self.message = textField.text;
}

- (IBAction)editingDidEndEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}





#pragma mark - MTTransportObserver
- (void)transportForURL:(NSURL *)aURL didReceiveMessageContent:(NSDictionary *)aMessageContent
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, aMessageContent);
}
- (void)transportDidConnectForURL:(NSURL *)aURL
{
}
- (void)transportDidCloseForURL:(NSURL *)aURL
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, [aURL absoluteString]);
}
- (void)transportDidFailForURL:(NSURL *)aURL error:(NSError *)anError
{
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, [aURL absoluteString]);
}

@end
