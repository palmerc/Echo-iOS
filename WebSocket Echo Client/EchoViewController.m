#import "EchoViewController.h"

#import "MTTransportManager.h"
#import "MTTransportDelegate.h"



static NSString *const kEchoWebsocketTestServerURL = @"ws://echo.websocket.org/";



@interface EchoViewController () <MTTransportDelegate>
@property (weak, nonatomic) MTTransportManager *transportManager;
@property (strong, nonatomic) NSURL *URL;
@property (assign, nonatomic, getter=isRepeating) BOOL repeat;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray *timers;
@property (copy, nonatomic) NSArray *responses;

@end



@implementation EchoViewController
@synthesize responses = _responses;

- (void)dealloc
{
    [[MTTransportManager sharedTransportManager] removeTransportDelegate:self forURL:self.URL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.URL = [NSURL URLWithString:kEchoWebsocketTestServerURL];

    MTTransportManager *transportManager = [MTTransportManager sharedTransportManager];
    [transportManager addTransportDelegate:self forURL:self.URL];
    self.transportManager = transportManager;
    self.responses = @[];
}

- (void)setRepeat:(BOOL)repeat
{
    _repeat = repeat;

    if (self.repeat) {
        [self.repeatButton setTitle:NSLocalizedString(@"Stop", @"Stop") forState:UIControlStateNormal];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
        [self addTimer:timer];
    } else {
        [self.repeatButton setTitle:NSLocalizedString(@"Repeat", @"Repeat") forState:UIControlStateNormal];
        for (NSTimer *timer in self.timers) {
            [self removeTimer:timer];
        }
        self.timers = nil;
    }
}

- (void)setResponses:(NSArray *)responses
{
    _responses = [responses copy];

    self.echoResponseTextView.text = [self.responses componentsJoinedByString:@"\n"];
}

- (void)addTimer:(NSTimer *)timer
{
    if (self.timers) {
        NSMutableArray *mutableTimers = [self.timers mutableCopy];
        [mutableTimers addObject:timer];
        self.timers = [mutableTimers copy];
    } else {
        self.timers = @[timer];
    }
}

- (void)removeTimer:(NSTimer *)timer
{
    if (self.timers) {
        NSMutableArray *mutableTimers = [self.timers mutableCopy];
        [mutableTimers removeObject:timer];
        if ([timer isValid]) {
            [timer invalidate];
        }
        self.timers = [mutableTimers copy];
    }
}



#pragma mark - MTTransportDelegate
- (void)didReceiveMessage:(id)aMessage forURL:(NSURL *)aURL
{
    if ([aMessage isKindOfClass:[NSString class]]) {
        NSUInteger count = [self.responses count];
        NSMutableArray *mutableResponses = [self.responses mutableCopy];
        NSString *annotatedMessage = [NSString stringWithFormat:@"%4lu, %@", count, aMessage];
        [mutableResponses addObject:annotatedMessage];
        self.responses = mutableResponses;
    }
}

- (void)transportFailed:(NSError *)anError forURL:(NSURL *)aURL
{
    NSString *fail = NSLocalizedString(@"Fail", @"Fail");
    NSString *failMessage = [NSString stringWithFormat:@"%@ - %@", fail, anError.localizedDescription];
    self.responses = [self.responses arrayByAddingObject:failMessage];
}

- (void)transportStateChanged:(MTTransportState)aState forURL:(NSURL *)aURL
{
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
}



#pragma mark - IBAction
- (IBAction)didPressRepeatButton:(id)sender
{
    self.repeat = !self.isRepeating;
}

- (IBAction)didPressSendButton:(id)sender
{
    if ([sender isKindOfClass:[NSTimer class]]) {
        NSTimer *timer = sender;
        [self removeTimer:timer];
    }

    [self.transportManager sendMessage:self.message forURL:self.URL];

    if (self.isRepeating) {
        if ([self.timers count] > 0) {
            NSLog(@"Number of outstanding timers: %lu", [self.timers count]);
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
        [self addTimer:timer];
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
