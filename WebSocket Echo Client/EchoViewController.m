#import "EchoViewController.h"
#import "MTTransportManager.h"



static NSString *const kEchoWebsocketTestServerURL = @"ws://echo.websocket.org/";



@interface EchoViewController ()
@property (weak, nonatomic) MTTransportManager *transportManager;
@property (strong, nonatomic) NSURL *URL;
@property (assign, nonatomic, getter=isRepeating) BOOL repeat;
@property (assign, nonatomic, getter=isConnected) BOOL connect;
@property (strong, nonatomic) NSString *message;
@property (copy, nonatomic) NSArray *responses;

@end



@implementation EchoViewController
@synthesize responses = _responses;

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
    self.responses = @[];
}

- (void)setConnect:(BOOL)connect
{
    _connect = connect;
}

- (void)setRepeat:(BOOL)repeat
{
    _repeat = repeat;

    if (self.repeat) {
        [NSTimer scheduledTimerWithTimeInterval:0.f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
    }
}

- (void)setResponses:(NSArray *)responses
{
    _responses = [responses copy];

    self.echoResponseTextView.text = [self.responses componentsJoinedByString:@"\n"];
}



#pragma mark - MTTransportHandlers

- (void (^)(id aMessage))onMessage
{
    return ^(id aMessage){
        NSMutableArray *mutableResponses = [self.responses mutableCopy];
        [mutableResponses addObject:aMessage];
        self.responses = mutableResponses;
    };
}

- (void (^)(NSError *anError))onFail
{
    return ^(NSError *anError){
        NSString *fail = NSLocalizedString(@"Fail", @"Fail");
        NSString *failMessage = [NSString stringWithFormat:@"%@ - %@", fail, anError.localizedDescription];
        self.responses = [self.responses arrayByAddingObject:failMessage];
    };}

- (void (^)(MTTransportState aState))onStateChange
{
    return ^(MTTransportState aState){
        switch (aState) {
            case TransportStateConnect:
            {
                NSString *connected = NSLocalizedString(@"Connected", @"Connected");
                self.responses = [@[] arrayByAddingObject:connected];
            }
                break;
            case TransportStateClose:
            {
                NSString *disconnected = NSLocalizedString(@"Disconnected", @"Disconnected");
                self.responses = [self.responses arrayByAddingObject:disconnected];
            }
                break;
            case TransportStateUnknown:
                break;
        }
    };
}



#pragma mark - IBAction
- (IBAction)didPressRepeatButton:(id)sender
{
    self.repeat = !self.isRepeating;
}

- (IBAction)didPressSendButton:(id)sender
{
    [self.transportManager sendMessage:self.message forURL:self.URL];

    if (self.isRepeating) {
        [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
    }
}

- (IBAction)editingDidBeginEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)editingChangedEchoTextField:(id)sender
{
    UITextField *textField = sender;
    self.message = textField.text;
}

- (IBAction)editingDidEndEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
