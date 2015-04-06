//
//  NSMutableArray+MultidimensionalAdditions.h
//  Anigraph
//
//  Created by Aaron Randall on 06/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MultidimensionalAdditions)

+ (NSMutableArray *) arrayOfWidth:(NSInteger) width andHeight:(NSInteger) height;

- (id) initWithWidth:(NSInteger) width andHeight:(NSInteger) height;

@end
