@import UIKit;



@interface NETHorseMovie : NSObject
@property (assign, nonatomic, readonly) NSUInteger width;
@property (assign, nonatomic, readonly) NSUInteger height;

- (UIImage *)nextFrame;
@end
