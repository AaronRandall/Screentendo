//
//  AppDelegate.m
//  TestGame
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"
#import "ImageStructureAnalyser.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    // Retrieve scene file path from the application bundle
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    // Unarchive the file to an SKScene object
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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeResizeFill;
    [self.skView presentScene:scene];

    // Sprite Kit applies additional optimizations to improve rendering performance
    self.skView.ignoresSiblingOrder = YES;
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
    
    [self makeWindowTransparent];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)makeWindowTransparent {
    self.window.opaque = NO;
    self.window.alphaValue = 0.3;
}

- (void)makeWindowOpaque {
    self.window.opaque = YES;
    self.window.alphaValue = 1;
}

@end
