#import "UIImage+ImageAdditions.h"



@implementation UIImage (ImageAdditions)
+ (UIImage *)net_imageFromGraylevelIntensities:(NSData *)pixels width:(NSUInteger)width height:(NSUInteger)height
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();

    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 1;
    size_t bitsPerPixel = bytesPerPixel * bitsPerComponent;
    size_t bytesPerRow = bytesPerPixel * width;

    const void *bytes = [pixels bytes];
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(nil, bytes, [pixels length], nil);
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        bitsPerComponent,
                                        bitsPerPixel,
                                        bytesPerRow,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        providerRef,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:imageRef];

    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);

    return image;
}

- (void)net_grayscaleIntensities:(void (^)(NSData *pixels, NSUInteger width, NSUInteger height))aCallback
{
    CGImageRef imageRef = self.CGImage;

    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 1;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = height * bytesPerRow;

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    void *buffer = malloc(totalBytes);
    CGContextRef contextRef = CGBitmapContextCreate(buffer,
                                                    width,
                                                    height,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorSpaceRef,
                                                    bitmapInfo);
    CGColorSpaceRelease(colorSpaceRef);
    CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), imageRef);
    CGContextRelease(contextRef);
    NSData *pixels = [NSData dataWithBytes:buffer length:totalBytes];
    free(buffer);

    aCallback(pixels, width, height);
}
@end
