//
//  NSMutableArray+MultidimensionalAdditions.m
//  Anigraph
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import "NSMutableArray+MultidimensionalAdditions.h"

@implementation NSMutableArray (MultidimensionalAdditions)

+ (NSMutableArray *) arrayOfWidth:(NSInteger) width andHeight:(NSInteger) height {
    return [[self alloc] initWithWidth:width andHeight:height];
}

- (id) initWithWidth:(NSInteger) width andHeight:(NSInteger) height {
    if((self = [self initWithCapacity:width])) {
        for(int i = 0; i < width; i++) {
            NSMutableArray *inner = [[NSMutableArray alloc] initWithCapacity:height];
            for(int j = 0; j < height; j++)
                [inner addObject:[NSNull null]];
            [self addObject:inner];
        }
    }
    return self;
}

@end