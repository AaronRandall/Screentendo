//
//  ImageStructureAnalyser.h
//  Screentendo
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStructureAnalyser : NSObject

+ (void)binaryArrayFromImage:(NSImage*)image
                   blockSize:(int)blockSize
                  completion:(void (^)(NSArray *imageBinaryArray))completion;

@end
