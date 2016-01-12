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

    self.URL = [NSURL URLWithString:kEchoWebsocketTestServerURL];

    MTTransportManager *transportManager = [MTTransportManager sharedTransportManager];
    [transportManager onMessage:[self onMessage] forURL:self.URL encoder:TransportMessageEncoderUTF8 queue:nil];
    [transportManager onFail:[self onFail] forURL:self.URL queue:nil];
    [transportManager onStateChange:[self onStateChange] forURL:self.URL queue:nil];

    self.transportManager = transportManager;
}

- (void)setConnect:(BOOL)connect
{
    _connect = connect;
}


#pragma mark - MTTransportHandlers

- (void (^)(id aMessage))onMessage
{
    return nil;
}

- (void (^)(NSError *anError))onFail
{
    return nil;
}

- (void (^)(MTTransportState aState))onStateChange
{
    return nil;
}


#pragma mark - IBAction
- (IBAction)didPressRepeatButton:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)didPressSendButton:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [self.transportManager sendMessage:self.message forURL:self.URL];
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
@end
