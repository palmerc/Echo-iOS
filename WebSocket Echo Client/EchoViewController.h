//
//  ViewController.h
//  Network Demo
//
//  Created by Cameron Palmer on 09.01.2016.
//  Copyright © 2016 NET. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EchoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *echoTextField;
@property (weak, nonatomic) IBOutlet UITextView *echoResponseTextView;
@property (weak, nonatomic) IBOutlet UIImageView *echoResponseImageView;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *messageTypeButton;

- (IBAction)didPressRepeatButton:(id)sender;
- (IBAction)didPressSendButton:(id)sender;
- (IBAction)didPressMessageTypeButton:(id)sender;
- (IBAction)editingDidBeginEchoTextField:(id)sender;
- (IBAction)editingChangedEchoTextField:(id)sender;
- (IBAction)editingDidEndEchoTextField:(id)sender;
@end

