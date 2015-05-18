//
//  AppDelegate.m
//  Screentendo
//
//  Created by Aaron Randall on 09/05/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"
#import "ImageStructureAnalyser.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation AppDelegate {
    GameScene *_scene;
}

const float transparentAlphaValue = 0.4f;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _scene = [GameScene unarchiveFromFile:@"GameScene"];
    _scene.scaleMode = SKSceneScaleModeResizeFill;
    
    self.skView.ignoresSiblingOrder = YES;
    self.skView.showsFPS = NO;
    self.window.delegate = self;
    
    [self.skView presentScene:_scene];
    [self makeWindowTransparent];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark -
#pragma mark Window actions

- (void)makeWindowTransparent {
    self.window.opaque = NO;
    self.window.alphaValue = transparentAlphaValue;
    _scene.backgroundColor = self.window.backgroundColor;
}

- (void)makeWindowOpaque {
    self.window.opaque = YES;
    self.window.alphaValue = 1;
}

- (void)windowWillMove:(NSNotification *)notification {
    [self makeWindowTransparent];
    [_scene resetScene];
}

#pragma mark -
#pragma mark Menu actions

- (IBAction)blockSizeSmallSelected:(id)sender {
    _scene.blockSize = 8;
    [self setAllMenuItemsToState:NSOffState];
    self.blockSizeSmallMenuItem.state = NSOnState;
}

- (IBAction)blockSizeMediumSelected:(id)sender {
    _scene.blockSize = 10;
    [self setAllMenuItemsToState:NSOffState];
    self.blockSizeMediumMenuItem.state = NSOnState;
}

- (IBAction)blockSizeLargeSelected:(id)sender {
    _scene.blockSize = 12;
    [self setAllMenuItemsToState:NSOffState];
    self.blockSizeLargeMenuItem.state = NSOnState;
}

- (void)setAllMenuItemsToState:(NSCellStateValue)state {
    self.blockSizeSmallMenuItem.state  = state;
    self.blockSizeMediumMenuItem.state = state;
    self.blockSizeLargeMenuItem.state  = state;
}

@end
