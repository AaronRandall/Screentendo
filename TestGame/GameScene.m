//
//  GameScene.m
//  TestGame
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "GameScene.h"
#import "ImageStructureAnalyser.h"
#import "AppDelegate.h"

@interface GameScene() <SKPhysicsContactDelegate>
@end

typedef NS_ENUM(NSInteger, Direction) {
    Left = 123,
    Right = 124,
    Up = 126,
    Down = 125
};

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    Direction _direction;
    BOOL _isJumping;
    
    BOOL _leftPressed;
    BOOL _rightPressed;
    BOOL _upPressed;
    BOOL _downPressed;
}

- (void) didChangeSize:(CGSize)oldSize {
    [self clearSpritesFromScene];
    [self makeAppWindowTransparent];
}

- (void)windowDidResize {
    NSLog(@"Window resized");
}

- (void) keyDown:(NSEvent *)event {
    switch([event keyCode]) {
        case Up:
            _upPressed = YES;
            break;
        case Down:
            _downPressed = YES;
            break;
        case Right:
            _rightPressed = YES;
            break;
        case Left:
            _leftPressed = YES;
            break;
        default:
            break;
    }
}

- (void) keyUp:(NSEvent *)event {
    switch([event keyCode]) {
        case Up:
            _upPressed = NO;
            break;
        case Down:
            _downPressed = NO;
            break;
        case Right:
            _rightPressed = NO;
            break;
        case Left:
            _leftPressed = NO;
            break;
        default:
            break;
    }
}

- (void) clearSpritesFromScene {
    [self removeAllChildren];
    [_blocks removeAllObjects];
}

- (void) makeAppWindowTransparent {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowTransparent];
}

- (void) makeAppWindowOpaque {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowOpaque];
}

- (void) mouseDown:(NSEvent *)theEvent {
    int blockSize = 10;
    
    [self clearSpritesFromScene];
    
//    NSArray *imageArray = [ImageStructureAnalyser topLevelWindowToBinaryArrayWithBlockSize:blockSize];
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    CGPoint location = [theEvent locationInNode:self];
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    _sprite.size = CGSizeMake(blockSize, blockSize * 2);
    _sprite.position = CGPointMake(location.x, location.y + 230);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sprite.size];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    _sprite.physicsBody.contactTestBitMask = 0;
    [self addChild:_sprite];
    
//    int blocksWide = (int)imageArray.count;
//    int blocksHigh = (int)[(NSArray*)[imageArray objectAtIndex:0] count];
//    
//    // Draw the blocks to the screen as images
//    for (int x = 0; x < blocksWide; x++) {
//        for (int y = 0; y < blocksHigh; y++) {
//            NSNumber *currentColor = imageArray[x][y];
//            
//            if ([currentColor isEqualToNumber:[NSNumber numberWithInt:1]]) {
//                SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
//                block.size = CGSizeMake(blockSize, blockSize);
//                block.position = CGPointMake(x*blockSize,(blocksHigh * blockSize) - y*blockSize);
//                block.scale = 1;
//                block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
//                block.physicsBody.dynamic = NO;
//                block.physicsBody.allowsRotation = NO;
//                block.physicsBody.usesPreciseCollisionDetection = YES;
//                block.physicsBody.affectedByGravity = NO;
//                block.physicsBody.contactTestBitMask = 1;
//                
//                [_blocks addObject:block];
//                [self addChild:block];
//            }
//        }
//    }
    
    [self makeAppWindowOpaque];
    
    // Hardcoded blocks
    int numBlocks = 20;
    for (int i = 0; i < numBlocks; i++) {
        SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
        block.size = CGSizeMake(blockSize, blockSize);
        block.position = CGPointMake(location.x + ((i*blockSize)-((numBlocks/2)*blockSize)),location.y);
        block.scale = 1;
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
        block.physicsBody.dynamic = NO;
        block.physicsBody.allowsRotation = NO;
        block.physicsBody.usesPreciseCollisionDetection = YES;
        block.physicsBody.affectedByGravity = NO;
        block.physicsBody.contactTestBitMask = 1;
        
        [_blocks addObject:block];
        [self addChild:block];
    }
}

- (void) renderPlayerPosition {
    int xDelta = 0;
    int yDelta = 0;
    
    if (_upPressed) {
        if (!_isJumping) {
            _isJumping = YES;
            [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, 1.5f) atPoint:_sprite.position];
        }
    } else if (_downPressed) {
        yDelta = -2;
    }
    
    if (_rightPressed) {
        xDelta = +2;
    } else if (_leftPressed) {
        xDelta = -2;
    }
    
    CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
    _sprite.position = desiredPosition;
    
   // _sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx + xDelta,_sprite.physicsBody.velocity.dy + yDelta);
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    //NSLog(@"Did begin contact");
    _isJumping = NO;
}

- (void) update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self renderPlayerPosition];
}

@end
