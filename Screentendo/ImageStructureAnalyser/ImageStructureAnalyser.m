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

+ (void)blocksFromImage:(NSImage*)image
              blockSize:(int)blockSize
        blockCalculated:(void (^)(NSDictionary *imageBinaryBlock))blockCalculated
             completion:(void (^)(NSArray *imageBinaryArray))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSImage *blackAndWhiteImage = [image toBlackAndWhiteBlocks];
        
        [blackAndWhiteImage toBinaryArrayWithBlockSize:blockSize blockCalculated:^(NSDictionary *imageBinaryBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                blockCalculated(imageBinaryBlock);
            });
        } completion:^(NSArray *imageBinaryArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imageBinaryArray);
            });
        }];
    });
}

@end
