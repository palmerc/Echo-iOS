#import "NETHorseMovie.h"



@interface NETHorseMovie ()
@property (strong, nonatomic) NSArray *horseFrameNames;
@property (assign, nonatomic) NSUInteger currentHorseFrame;
@property (assign, nonatomic, readwrite) NSUInteger width;
@property (assign, nonatomic, readwrite) NSUInteger height;
@end



@implementation NETHorseMovie

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        _currentHorseFrame = 0;
        _horseFrameNames = @[@"Horse01",
                             @"Horse02",
                             @"Horse03",
                             @"Horse04",
                             @"Horse05",
                             @"Horse06",
                             @"Horse07",
                             @"Horse08",
                             @"Horse09",
                             @"Horse10",
                             @"Horse11",
                             @"Horse12"];
    }

    return self;
}

- (UIImage *)nextFrame
{
    NSLog(@"Current horse frame: %lu", self.currentHorseFrame);
    NSString *horseFrameName = self.horseFrameNames[self.currentHorseFrame];
    UIImage *image = [UIImage imageNamed:horseFrameName];
    self.width = image.size.width;
    self.height = image.size.height;
    if (self.currentHorseFrame < [self.horseFrameNames count] - 3) {
        self.currentHorseFrame++;
    } else {
        self.currentHorseFrame = 0;
    }

    return image;
}
@end
