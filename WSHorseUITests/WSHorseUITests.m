#import <XCTest/XCTest.h>

@interface WSHorseUITests : XCTestCase
@property (strong, nonatomic) XCUIApplication *application;
@property (strong, nonatomic) XCUIElement *sendButton;
@property (strong, nonatomic) XCUIElement *repeatButton;
@property (strong, nonatomic) XCUIElement *dataTypeButton;
@end

@implementation WSHorseUITests

- (void)setUp {
    self.continueAfterFailure = NO;
    
    self.application = [[XCUIApplication alloc] init];
    [self.application launch];
    
    self.sendButton = self.application.buttons[@"sendButton"];
    self.repeatButton = self.application.buttons[@"repeatButton"];
    self.dataTypeButton = self.application.buttons[@"messageTypeButton"];

}

- (void)tearDown {
}

- (void)testHelloWorld {
    [self.sendButton tap];
    
    NSPredicate *echoResponsePredicate = [NSPredicate predicateWithFormat:@"value CONTAINS[c] '0, Hello, World!'"];
    XCUIElement *echoResponseTextView = self.application.textViews[@"echoResponseTextView"];
    [self expectationForPredicate:echoResponsePredicate evaluatedWithObject:echoResponseTextView handler:nil];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testRepeatingHelloWorld {
    [self.repeatButton tap];

    NSPredicate *echoResponsePredicate = [NSPredicate predicateWithFormat:@"value CONTAINS[c] '5, Hello, World!'"];
    XCUIElement *echoResponseTextView = self.application.textViews[@"echoResponseTextView"];
    [self expectationForPredicate:echoResponsePredicate evaluatedWithObject:echoResponseTextView handler:nil];
    [self waitForExpectationsWithTimeout:30.0f handler:nil];
}

- (void)testBinaryHorse {
    [self.dataTypeButton tap];
    [self.sendButton tap];
    
    NSPredicate *echoResponsePredicate = [NSPredicate predicateWithFormat:@"value CONTAINS[c] '0, Received 82800 bytes'"];
    XCUIElement *echoResponseTextView = self.application.textViews[@"echoResponseTextView"];
    [self expectationForPredicate:echoResponsePredicate evaluatedWithObject:echoResponseTextView handler:nil];
    [self waitForExpectationsWithTimeout:10.0f handler:nil];
}

- (void)testRepeatingBinaryHorse {
    [self.dataTypeButton tap];
    [self.repeatButton tap];
    
    NSPredicate *echoResponsePredicate = [NSPredicate predicateWithFormat:@"value CONTAINS[c] '5, Received 82800 bytes'"];
    XCUIElement *echoResponseTextView = self.application.textViews[@"echoResponseTextView"];
    [self expectationForPredicate:echoResponsePredicate evaluatedWithObject:echoResponseTextView handler:nil];
    [self waitForExpectationsWithTimeout:30.0f handler:nil];
}

@end
