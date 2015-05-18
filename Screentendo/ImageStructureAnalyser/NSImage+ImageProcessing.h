//
//  NSImage+ImageProcessing.h
//  Anigraph
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSImage (ImageProcessing)

- (NSImage*)toBlackAndWhiteBlocks;
- (void)toBinaryArrayWithBlockSize:(int)blockSize
                   blockCalculated:(void (^)(NSDictionary *imageBinaryBlock))blockCalculated
                        completion:(void (^)(NSArray *imageBinaryArray))completion;

@end
