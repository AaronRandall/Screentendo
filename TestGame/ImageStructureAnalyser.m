//
//  ImageStructureAnalyser.m
//  TestGame
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "ImageStructureAnalyser.h"
#import "Window.h"
#import "NSImage+ImageProcessing.h"

@implementation ImageStructureAnalyser

+ (NSArray*)topLevelWindowToBinaryArrayWithBlockSize:(int)blockSize {
    NSImage *image = [Window croppedImageOfTopLevelWindow];
    image = [image toBlackAndWhiteBlocks];
    NSMutableArray *imageArray = [image toBinaryArrayWithBlockSize:blockSize];
    return imageArray;
}

@end
