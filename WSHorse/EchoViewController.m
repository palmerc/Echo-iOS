#import "EchoViewController.h"

#import <SocketRocket/SocketRocket.h>
#import <AZSClient/AZSClient.h>

#import "NETHorseMovie.h"
#import "UIImage+ImageAdditions.h"



static NSString *const kEchoWebsocketTestServerURL = @"ws://echo.websocket.org/";
//static NSString *const kEchoWebsocketTestServerURL = @"ws://127.0.0.1:9000/";
typedef NS_ENUM(NSUInteger, NETMessageType) {
    kNETMessageTypeString,
    kNETMessageTypeBinary
};



@interface EchoViewController () <SRWebSocketDelegate, UITextViewDelegate>
@property (strong, nonatomic) NETHorseMovie *horseMovie;
@property (strong, nonatomic) AZSCloudBlobContainer *blobContainer;
@property (strong, nonatomic) SRWebSocket *webSocket;
@property (assign, nonatomic, getter=isRepeating) BOOL repeat;
@property (strong, nonatomic) NSString *textMessage;
@property (assign, nonatomic) NETMessageType messageType;
@property (strong, nonatomic) NSArray *timers;
@property (copy, nonatomic) NSArray *textResponses;
@property (assign, nonatomic) UIImage *image;

@end



@implementation EchoViewController
- (void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.messageType = kNETMessageTypeString;
    NETHorseMovie *horseMovie = [[NETHorseMovie alloc] init];
    self.horseMovie = horseMovie;

    self.textResponses = @[];
    
    self.textMessage = @"Hello, World!";
    
    [self uploadAppSigning];
}

- (void)uploadAppSigning
{
    NSString *azurePath = [[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"];
    NSDictionary *azurePlist = [NSDictionary dictionaryWithContentsOfFile:azurePath];
    
    NSString *blobStoreURI = [azurePlist objectForKey:@"BlobStore"];
    if ([blobStoreURI length] > 0) {
        NSURL *blobContainerURL = [NSURL URLWithString:blobStoreURI];

        // Placeholder for the DER encoded signing
        NSData *der = [self.textMessage dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        self.blobContainer = [[AZSCloudBlobContainer alloc] initWithUrl:blobContainerURL error:&error];
        
        // Name of blob will be a SHA-1 sum of the binary blob
        NSString *blobName = @"Testing123";
        AZSCloudBlockBlob *blob = [self.blobContainer blockBlobReferenceFromName:blobName];
        [blob uploadFromData:der completionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"Uploaded DER encoded signing - %lu bytes", (unsigned long)[der length]);
            }
        }];
    }
}

- (void)setRepeat:(BOOL)repeat
{
    _repeat = repeat;

    if (self.repeat) {
        [self.repeatButton setTitle:NSLocalizedString(@"Stop", @"Stop") forState:UIControlStateNormal];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
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

    [self.echoResponseTextView scrollRangeToVisible:NSMakeRange([self.echoResponseTextView.text length] - 1, 0)];
}

- (void)setTextMessage:(NSString *)textMessage
{
    if (![textMessage isEqualToString:_textMessage]) {
        _textMessage = textMessage;
        
        self.echoTextField.text = textMessage;
    }
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
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)aMessage
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

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    self.webSocket = nil;
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self sendMessage:nil];
}



#pragma mark -

- (id)message
{
    __block id message;
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
    
    return message;
}

- (void)sendMessage:(id)sender
{
    if ([sender isKindOfClass:[NSTimer class]]) {
        NSTimer *timer = sender;
        [self removeTimer:timer];
    }
    
    if (self.webSocket == nil) {
        SRWebSocket *webSocket = [[SRWebSocket alloc] initWithURL: [NSURL URLWithString: kEchoWebsocketTestServerURL]];
        webSocket.delegate = self;
        [webSocket open];
        self.webSocket = webSocket;
    } else if (self.webSocket.readyState == SR_OPEN) {
        [self.webSocket send:[self message]];
    }
    
    if (self.isRepeating) {
        if ([self.timers count] > 0) {
            NSLog(@"Number of outstanding timers: %lu", [self.timers count]);
        }
        
        NSTimeInterval timeInterval = 0.f;
        switch (self.messageType) {
            case kNETMessageTypeString:
                timeInterval = 1.f;
                break;
            case kNETMessageTypeBinary:
                timeInterval = 0.1f;
                break;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(didPressSendButton:) userInfo:nil repeats:NO];
        [self addTimer:timer];
    }
}


#pragma mark - IBAction
- (IBAction)didPressRepeatButton:(id)sender
{
    self.repeat = !self.isRepeating;
}

- (IBAction)didPressSendButton:(id)sender
{
    [self sendMessage:sender];
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
