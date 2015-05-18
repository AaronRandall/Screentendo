//
//  NSImage+ImageProcessing.m
//  Anigraph
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import "NSImage+ImageProcessing.h"
#import "NSMutableArray+MultidimensionalAdditions.h"
#import <GPUImage.h>

@implementation NSImage (ImageProcessing)

- (NSImage*)toBlackAndWhiteBlocks {
    NSImage *image = self;
    
    image = [self motionBlurImage:image];
    image = [self luminanceFilterImage:image];
    image = [self pixelateImage:image];
    image = [self blackAndWhiteImage:image];
    
    return image;
}

- (void)toBinaryArrayWithBlockSize:(int)blockSize
                   blockCalculated:(void (^)(NSDictionary *))blockCalculated
                        completion:(void (^)(NSArray *))completion
{
    NSMutableArray *images = [self splitImageIntoBlocks:self withBlockSize:blockSize];
    
    int width = (int)self.size.width/blockSize;
    int height = (int)self.size.height/blockSize;
    
    NSMutableArray *imageArray = [NSMutableArray arrayOfWidth:width andHeight:height];
    
    // Calculate the average color of the blocks
    int counter = 0;
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            NSImage *theImage = images[counter];
            counter = counter + 1;
            
            NSColor *averageColor = [self averageColor:theImage];
            NSNumber *avgColor = [NSNumber numberWithInt:0];
            
            if (averageColor.redComponent > 0.7) {
                // Mostly white image, no need to change value
            } else {
                // Mostly black image
                avgColor = [NSNumber numberWithInt:1];
            }
            
            [[imageArray objectAtIndex:x] setObject:avgColor atIndex:y];
            
            blockCalculated(@{@"x":[NSNumber numberWithInt:x], @"y":[NSNumber numberWithInt:y], @"binaryValue": avgColor});
        }
    }
    
    completion(imageArray);
}

- (NSMutableArray *)splitImageIntoBlocks:(NSImage *)image withBlockSize:(NSInteger)blockSize
{
    NSMutableArray *images = [NSMutableArray array];
    CGSize imageSize = image.size;
    CGFloat xPos = 0.0, yPos = 0.0;
    int blocksWide = imageSize.width/blockSize;
    int blocksHigh = imageSize.height/blockSize;
    
    for (int y = 0; y < blocksHigh; y++) {
        xPos = 0.0;
        for (int x = 0; x < blocksWide; x++) {
            
            CGRect rect = CGRectMake(xPos, yPos, blockSize, blockSize);
            CGImageRef cImage = CGImageCreateWithImageInRect([self nsImageToCGImageRef:image],  rect);
            
            NSImage *dImage = [[NSImage alloc] initWithCGImage:cImage size:rect.size];
            [images addObject:dImage];
            xPos += blockSize;
        }
        yPos += blockSize;
    }
    return images;
}

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    return imageRef;
}

# pragma mark -
# pragma mark Image processing

- (NSImage*)motionBlurImage:(NSImage*)image {
    GPUImageMotionBlurFilter *imageFilter = [[GPUImageMotionBlurFilter alloc] init];
    imageFilter.blurAngle = 0;
    imageFilter.blurSize = 3;
    return [imageFilter imageByFilteringImage:image];
}

- (NSImage*)luminanceFilterImage:(NSImage*)image {
    GPUImageAverageLuminanceThresholdFilter *imageFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
    return [imageFilter imageByFilteringImage:image];
}

- (NSImage*)pixelateImage:(NSImage*)image {
    GPUImagePixellateFilter *imageFilter = [[GPUImagePixellateFilter alloc] init];
    imageFilter.fractionalWidthOfAPixel = 0.009;
    return [imageFilter imageByFilteringImage:image];
}

- (NSImage*)blackAndWhiteImage:(NSImage*)image {
    GPUImageLuminanceThresholdFilter *imageFilter = [[GPUImageLuminanceThresholdFilter alloc] init];
    return [imageFilter imageByFilteringImage:image];
}

- (NSColor *)averageColor:(NSImage*)image{
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), [self nsImageToCGImageRef:image]);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [NSColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [NSColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end