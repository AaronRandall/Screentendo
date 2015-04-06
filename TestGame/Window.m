//
//  Window.m
//  Anigraph
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron. All rights reserved.
//

#import "Window.h"
#import <GPUImage.h>

@implementation Window {
    NSDictionary *_windowDictionary;
}

- (id)initWithDictionary:(NSDictionary*)windowDictionary
{
    self = [super init];
    if (self) {
        _windowDictionary = windowDictionary;
    }
    return self;
}

- (NSString*)name {
    return _windowDictionary[@"kCGWindowName"];
}

- (NSString*)ownerName {
    return _windowDictionary[@"kCGWindowOwnerName"];
}

- (CGRect)bounds {
    NSDictionary *b = _windowDictionary[@"kCGWindowBounds"];
    
    CGRect rect = CGRectMake([b[@"X"] floatValue], [b[@"Y"] floatValue], [b[@"Width"] floatValue], [b[@"Height"] floatValue]);
    
    return rect;
}

- (int)number {
    return [_windowDictionary[@"kCGWindowNumber"] intValue];
}

- (int)layer {
    return [_windowDictionary[@"kCGWindowLayer"] intValue];
}

- (NSImage*)takeScreenshot {
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull,
                                                     kCGWindowListOptionIncludingWindow,
                                                     (CGWindowID)self.number,
                                                     kCGWindowImageBoundsIgnoreFraming);
    
    return [self imageFromCGImageRef:windowImage];
}

- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
    
    // Create a new image to receive the Quartz image data.
    NSImage* newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
    
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus];
    return newImage;
}

# pragma mark -
# pragma mark Class methods

+ (Window*)getWindowAtLayer:(int)layer andIndex:(int)index {
    int indexCounter = 0;
    
    for (Window *window in [self listOfWindows]) {
        if (window.layer != layer) {
            continue;
        } else {
            NSLog(@"");
            if (window.name.length > 0 &&
                ![window.ownerName isEqualToString:@"Xcode"] &&
                ![window.ownerName isEqualToString:@"MagicGraphDebugWindow"]) {
                if (indexCounter == index) {
                    return window;
                }
                
                indexCounter++;
            }
        }
    }
    
    return nil;
}

+ (NSArray*)listOfWindows {
    CFArrayRef listOfWindows = CGWindowListCopyWindowInfo(kCGWindowListExcludeDesktopElements | kCGWindowListOptionOnScreenOnly,kCGNullWindowID );
    
    NSMutableArray *windows = [NSMutableArray array];
    
    for (NSDictionary *currentWindow in (__bridge NSArray*)listOfWindows) {
        [windows addObject:[[Window alloc] initWithDictionary:currentWindow]];
    }
    
    return windows;
}

@end
