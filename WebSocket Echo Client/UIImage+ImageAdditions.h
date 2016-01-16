@import UIKit;



@interface UIImage (ImageAdditions)
+ (UIImage *)net_imageFromGraylevelIntensities:(NSData *)pixelValues width:(NSUInteger)width height:(NSUInteger)height;

- (void)net_grayscaleIntensities:(void (^)(NSData *pixels, NSUInteger width, NSUInteger height))aCallback;
@end
