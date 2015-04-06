//
//  ImageStructureAnalyser.h
//  TestGame
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStructureAnalyser : NSObject

+ (NSArray*)topLevelWindowToBinaryArrayWithBlockSize:(int)blockSize;

@end
