//
//  ImageStructureAnalyser.m
//  Screentendo
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "ImageStructureAnalyser.h"
#import "NSImage+ImageProcessing.h"

@implementation ImageStructureAnalyser

+ (void)binaryArrayFromImage:(NSImage*)image
                      blockSize:(int)blockSize
                    completion:(void (^)(NSArray *imageArray))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableArray *imageArray = [[image toBlackAndWhiteBlocks] toBinaryArrayWithBlockSize:blockSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(imageArray);
        });
    });
}

@end
