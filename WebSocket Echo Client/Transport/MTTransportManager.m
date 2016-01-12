#pragma mark - Imports
#import "MTTransportManager.h"
#import "NSObject+Additions.h"



#pragma mark - Constants



#pragma mark - Private Category
@interface MTTransportManager ()
@property (strong, nonatomic) NSMutableDictionary *transports;
@property (strong, nonatomic) NSThread *transportThread;
@property (strong, nonatomic) NSMutableDictionary *observers;
@property (strong, nonatomic) NSURL *waitingOpenTransportURL;
@property (assign, nonatomic) BOOL isWaitingTransportStateChange;
@end



#pragma mark - Implementation
@implementation MTTransportManager
+ (MTTransportManager *)sharedTransportManager
{
    static dispatch_once_t onceToken;
    static MTTransportManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MTTransportManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
    }
    return self;
}

- (void)onMessage:(void (^)(id aMessage))aCallback
           forURL:(NSURL *)aURL
          encoder:(MTTransportMessageEncoder)anEncoder
            queue:(dispatch_queue_t)aQueue
{

}

- (void)onFail:(void (^)(NSError *anError))aCallback
        forURL:(NSURL *)aURL
         queue:(dispatch_queue_t)aQueue
{

}

- (void)onStateChange:(void (^)(MTTransportState aState))aCallback
               forURL:(NSURL *)aURL
                queue:(dispatch_queue_t)aQueue
{

}

- (void)sendMessage:(id)aMessage forURL:(NSURL *)aURL
{

}

- (void)closeTransportForURL:(NSURL *)aURL
{

}

- (void)closeAllTransports
{

}

//
//- (void)sendContent:(id)aContent forURL:(NSURL *)aURL
//{
//    [self mt_performBlock:^{
//            @synchronized (self) {
//                MTTransportBase *transport = self.transports[aURL];
//                if (transport == nil) {
//                    if (([[aURL scheme] isEqualToString:@"wss"]) ||
//                        ([[aURL scheme] isEqualToString:@"ws"])) {
//                        transport = [[MTTransportWebSocket alloc] initWithURL:aURL];
//                        if (transport != nil) {
//                            self.transports[aURL] = transport;
//                            transport.delegate = self;
//                            [transport scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//                            [transport open];
//                        }
//                    } else {
//                        NSLog(@"No transport for URL %@", aURL);
//                    }
//               }
//               
//               [transport sendContent:aContent];
//           }
//        } 
//    onThread:self.transportThread waitUntilDone:NO];
//}
//
//- (void)resetAllTransports
//{
//    [self mt_performBlock:^{
//            @synchronized (self) {
//                NSEnumerator *keyEnumerator = [self.transports keyEnumerator];
//                NSURL *key = nil;
//                while (nil != (key = [keyEnumerator nextObject])) {
//                    MTTransportBase *transport = self.transports[key];
//                    transport.delegate = nil;
//                    [transport removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//                    [transport close];
//                }
//                [self.transports removeAllObjects];
//            }
//        } 
//    onThread:self.transportThread waitUntilDone:NO];
//}
//
//- (void)openTransportForURL:(NSURL *)aURL
//{
//    __block MTTransportWebSocket *transport = nil;
//    @synchronized (self) {
//        transport = self.transports[aURL];
//        if (transport == nil) {
//            if ( ([[aURL scheme] isEqualToString:@"ws"]) || ([[aURL scheme] isEqualToString:@"wss"]) ) {
//                transport = [[MTTransportWebSocket alloc] initWithURL:aURL];
//                self.transports[aURL] = transport;
//                [self mt_performBlock:^{
//                    self.waitingOpenTransportURL = aURL;
//                    self.isWaitingTransportStateChange = NO;
//
//                    transport.delegate = self;
//                    [transport scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//                    [transport open];
//
//                    NSDate *expire = [NSDate dateWithTimeIntervalSinceNow:3.f];
//                    while (!self.isWaitingTransportStateChange && [expire timeIntervalSinceNow] > 0) {
//                        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
//                    }
//                } onThread:self.transportThread waitUntilDone:NO];
//            }
//        }
//    }
//}
//
//- (void)resetTransportForURL:(NSURL *)aURL
//{
//    [self mt_performBlock:^{
//        @synchronized (self) {
//            MTTransportBase *transport = self.transports[aURL];
//            transport.delegate = nil;
//            [transport close];
//            [self.transports removeObjectForKey:aURL];
//           }
//       }
//    onThread:self.transportThread waitUntilDone:YES];
//}
//
//- (NSThread *)payloadThread
//{
//    NSThread *result = self.transportThread;
//    if (result == nil) {
//        result = [NSThread mainThread];
//    }
//    return result;
//}
//


//#pragma mark - MTTransportObserver
//- (void)transportDidOpen:(MTTransportBase *)aTransport
//{
//    if ([aTransport.URL isEqual:self.waitingOpenTransportURL]) {
//        self.isWaitingTransportStateChange = YES;
//    }
//    
//    NSURL *transportURL = aTransport.URL;
//    [self mt_performBlock:^{
//        NSArray *observers = [self.observers[transportURL] copy];
//        for (id<MTTransportObserver> observer in observers) {
//            if ([observer respondsToSelector:@selector(transportDidConnectForURL:)]) {
//                [observer transportDidConnectForURL:transportURL];
//            }
//        }
//    } onThread:[NSThread mainThread] waitUntilDone:NO];
//}
//
//- (void)transportDidClose:(MTTransportBase *)aTransport
//{
//    if ([aTransport.URL isEqual:self.waitingOpenTransportURL]) {
//        self.isWaitingTransportStateChange = YES;
//    }
//    aTransport.delegate = nil;
//    [aTransport removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    NSURL *transportURL = aTransport.URL;
//    @synchronized (self) {
//        [self.transports removeObjectForKey:transportURL];
//    }
//    
//    [self mt_performBlock:^{
//            NSArray *observers = [self.observers[transportURL] copy];
//            for (id<MTTransportObserver> observer in observers) {
//                if ([observer respondsToSelector:@selector(transportDidCloseForURL:)]) {
//                    [observer transportDidCloseForURL:transportURL];
//                }
//            }
//        } 
//    onThread:[NSThread mainThread] waitUntilDone:NO];
//}
//
//- (void)transportDidFail:(MTTransportBase *)aTransport error:(NSError *)anError
//{
//    if ([aTransport.URL isEqual:self.waitingOpenTransportURL]) {
//        self.isWaitingTransportStateChange = YES;
//    }
//    aTransport.delegate = nil;
//    [aTransport removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//    NSURL *transportURL = aTransport.URL;
//    NSError *error = anError;
//    @synchronized (self) {
//        [self.transports removeObjectForKey:transportURL];
//    }
//    
//    [self mt_performBlock:^{
//            NSArray *observers = [self.observers[transportURL] copy];
//            for (id<MTTransportObserver> observer in observers) {
//                if ([observer respondsToSelector:@selector(transportDidFailForURL:error:)]) {
//                    [observer transportDidFailForURL:transportURL error:error];
//                }
//            }
//        } 
//    onThread:[NSThread mainThread] waitUntilDone:NO];
//}
//
//- (void)transport:(MTTransportBase *)aTransport didReceiveMessageContent:(NSDictionary *)aMessageContent
//{
//    NSURL *transportURL = aTransport.URL;
//    [self mt_performBlock:^{
//            NSArray *observers = [self.observers[transportURL] copy];
//            for (id<MTTransportObserver> observer in observers) {
//                if ([observer respondsToSelector:@selector(transportForURL:didReceiveMessageContent:)]) {
//                    [observer transportForURL:transportURL didReceiveMessageContent:aMessageContent];
//                }
//            }
//        } 
//    onThread:[NSThread mainThread] waitUntilDone:NO];
//}



#pragma mark - Private
//
//- (NSMutableDictionary *)transports
//{
//    if (_transports == nil) {
//        self.transports = [[NSMutableDictionary alloc] init];
//    }
//
//    return _transports;
//}
//
//- (NSMutableDictionary *)observers
//{
//    if (_observers == nil) {
//        self.observers = [[NSMutableDictionary alloc] init];
//    }
//
//    return _observers;
//}
//
//- (NSThread *)transportThread
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSThread *transportThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadedLoop) object:nil];
//        [transportThread start];
//        self.transportThread = transportThread;
//    });
//
//    return _transportThread;
//}
//
//- (void)threadedLoop
//{
//    @autoreleasepool {
//        NSLog(@"Entering the network thread run loop.");
//
//        while (YES) {
//            @autoreleasepool {
//                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1.f]];
//            }
//        }
//    }    
//}
@end
