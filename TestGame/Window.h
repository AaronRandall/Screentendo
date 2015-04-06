//
//  Window.h
//  Anigraph
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Window : NSObject

+ (Window*)getWindowAtLayer:(int)layer andIndex:(int)index;
+ (NSArray*)listOfWindows;
+ (NSImage*)croppedImageOfTopLevelWindow;

- (NSString*)name;
- (NSString*)ownerName;
- (CGRect)bounds;
- (int)number;
- (int)layer;
- (NSImage*)takeScreenshot;

@end
