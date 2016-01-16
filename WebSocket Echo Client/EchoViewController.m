#import "EchoViewController.h"

#import "MTTransportManager.h"
#import "MTTransportDelegate.h"
#import "NETHorseMovie.h"
#import "UIImage+ImageAdditions.h"



//static NSString *const kEchoWebsocketTestServerURL = @"ws://echo.websocket.org/";
static NSString *const kEchoWebsocketTestServerURL = @"ws://127.0.0.1:9000/";
typedef NS_ENUM(NSUInteger, NETMessageType) {
    kNETMessageTypeString,
    kNETMessageTypeBinary
};



@interface EchoViewController () <MTTransportDelegate>
@property (weak, nonatomic) MTTransportManager *transportManager;
@property (strong, nonatomic) NETHorseMovie *horseMovie;
@property (strong, nonatomic) NSURL *URL;
@property (assign, nonatomic, getter=isRepeating) BOOL repeat;
@property (strong, nonatomic) NSString *textMessage;
@property (assign, nonatomic) NETMessageType messageType;
@property (strong, nonatomic) NSArray *timers;
@property (copy, nonatomic) NSArray *textResponses;
@property (strong, nonatomic) UIImage *image;

@end



@implementation EchoViewController
- (void)dealloc
{
    [[MTTransportManager sharedTransportManager] removeTransportDelegate:self forURL:self.URL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.URL = [NSURL URLWithString:kEchoWebsocketTestServerURL];

    self.messageType = kNETMessageTypeString;
    NETHorseMovie *horseMovie = [[NETHorseMovie alloc] init];
    self.horseMovie = horseMovie;

    MTTransportManager *transportManager = [MTTransportManager sharedTransportManager];
    [transportManager addTransportDelegate:self forURL:self.URL];
    self.transportManager = transportManager;
    self.textResponses = @[];
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

- (void)setImage:(UIImage *)image
{
    _image = image;

    self.echoResponseImageView.image = image;
}

- (void)setTextResponses:(NSArray *)textResponses
{
    _textResponses = [textResponses copy];

    self.echoResponseTextView.text = [self.textResponses componentsJoinedByString:@"\n"];
}

- (void)setMessageType:(NETMessageType)messageType
{
    _messageType = messageType;

    NSString *title = nil;
    switch (messageType) {
        case kNETMessageTypeBinary:
            title = NSLocalizedString(@"Binary", @"Binary");
            break;
        case kNETMessageTypeString:
            title = NSLocalizedString(@"UTF-8", @"UTF-8");
            break;
    }

    [self.messageTypeButton setTitle:title forState:UIControlStateNormal];
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
        NSUInteger count = [self.textResponses count];
        NSMutableArray *mutableResponses = [self.textResponses mutableCopy];
        NSString *annotatedMessage = [NSString stringWithFormat:@"%4lu, %@", count, aMessage];
        [mutableResponses addObject:annotatedMessage];
        self.textResponses = mutableResponses;
    } else if ([aMessage isKindOfClass:[NSData class]]) {
        NSUInteger count = [self.textResponses count];
        NSMutableArray *mutableResponses = [self.textResponses mutableCopy];
        NSString *annotatedMessage = [NSString stringWithFormat:@"%4lu, Received %lu bytes", count, [aMessage length]];
        [mutableResponses addObject:annotatedMessage];
        self.textResponses = mutableResponses;

        UIImage *image = [UIImage net_imageFromGraylevelIntensities:aMessage width:self.horseMovie.width height:self.horseMovie.height];
        self.image = image;
    }
}

- (void)transportFailed:(NSError *)anError forURL:(NSURL *)aURL
{
    NSString *fail = NSLocalizedString(@"Fail", @"Fail");
    NSString *failMessage = [NSString stringWithFormat:@"%@ - %@", fail, anError.localizedDescription];
    self.textResponses = [self.textResponses arrayByAddingObject:failMessage];
}

- (void)transportStateChanged:(MTTransportState)aState forURL:(NSURL *)aURL
{
    switch (aState) {
        case TransportStateConnect:
        {
            NSString *connected = NSLocalizedString(@"Connected", @"Connected");
            self.textResponses = [@[] arrayByAddingObject:connected];
        }
            break;
        case TransportStateClose:
        {
            NSString *disconnected = NSLocalizedString(@"Disconnected", @"Disconnected");
            self.textResponses = [self.textResponses arrayByAddingObject:disconnected];
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

    __block id message = nil;
    switch (self.messageType) {
        case kNETMessageTypeString:
            message = self.textMessage;
            break;
        case kNETMessageTypeBinary:
        {
            [[self.horseMovie nextFrame] net_grayscaleIntensities:^(NSData *pixels, NSUInteger width, NSUInteger height) {
                message = pixels;
            }];
        }
    }
    [self.transportManager sendMessage:message forURL:self.URL];

    if (self.isRepeating) {
        if ([self.timers count] > 0) {
            NSLog(@"Number of outstanding timers: %lu", [self.timers count]);
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
        [self addTimer:timer];
    }
}

- (IBAction)didPressMessageTypeButton:(id)sender
{
    switch (self.messageType) {
        case kNETMessageTypeString:
            self.messageType = kNETMessageTypeBinary;
            break;
        case kNETMessageTypeBinary:
            self.messageType = kNETMessageTypeString;
            break;
    }
}

- (IBAction)editingDidBeginEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)editingChangedEchoTextField:(id)sender
{
    UITextField *textField = sender;
    self.textMessage = textField.text;
}

- (IBAction)editingDidEndEchoTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}
@end
