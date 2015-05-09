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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _scene = [GameScene unarchiveFromFile:@"GameScene"];
    
    // Set the scale mode to scale to fit the window
    _scene.scaleMode = SKSceneScaleModeResizeFill;
    [self.skView presentScene:_scene];
    
    self.skView.ignoresSiblingOrder = YES;
    self.skView.showsFPS = NO;
    self.skView.showsNodeCount = NO;
    
    [self makeWindowTransparent];
    
    self.window.delegate = self;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)makeWindowTransparent {
    self.window.opaque = NO;
    self.window.alphaValue = 0.4;
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

- (IBAction)blockSizeSmallSelected:(id)sender {
    _scene.blockSize = 8;
    
    self.blockSizeSmallMenuItem.state = NSOnState;
    self.blockSizeMediumMenuItem.state = NSOffState;
    self.blockSizeLargeMenuItem.state = NSOffState;
}

- (IBAction)blockSizeMediumSelected:(id)sender {
    _scene.blockSize = 10;
    
    self.blockSizeSmallMenuItem.state = NSOffState;
    self.blockSizeMediumMenuItem.state = NSOnState;
    self.blockSizeLargeMenuItem.state = NSOffState;
}

- (IBAction)blockSizeLargeSelected:(id)sender {
    _scene.blockSize = 12;
    
    self.blockSizeSmallMenuItem.state = NSOffState;
    self.blockSizeMediumMenuItem.state = NSOffState;
    self.blockSizeLargeMenuItem.state = NSOnState;
}

@end
