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
    Left  = 123,
    Right = 124,
    Up    = 126,
    Down  = 125
};

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    BOOL _isJumping;
    BOOL _isFacingLeft;
    
    BOOL _leftPressed;
    BOOL _rightPressed;
    BOOL _upPressed;
    BOOL _downPressed;
    
    int _frameCount;
    int _animationTicker;
}

// Debug
const bool _hardcodeBlocks = NO;

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

    NSArray *imageArray = nil;
    if (!_hardcodeBlocks) {
        imageArray = [ImageStructureAnalyser topLevelWindowToBinaryArrayWithBlockSize:blockSize];
    }
    
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
    
    CGPoint location = [theEvent locationInNode:self];
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player-standing-right"];
    _sprite.size = CGSizeMake(blockSize, blockSize * 2);
    _sprite.position = CGPointMake(location.x, location.y + 230);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_sprite.size.width, _sprite.size.height)];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    _sprite.physicsBody.contactTestBitMask = 0;
    
    [self addChild:_sprite];
    
    if (!_hardcodeBlocks) {
        int blocksWide = (int)imageArray.count;
        int blocksHigh = (int)[(NSArray*)[imageArray objectAtIndex:0] count];
        
        // Draw the blocks to the screen as images
        for (int x = 0; x < blocksWide; x++) {
            for (int y = 0; y < blocksHigh; y++) {
                NSNumber *currentColor = imageArray[x][y];
                
                if ([currentColor isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
                    block.size = CGSizeMake(blockSize, blockSize);
                    block.position = CGPointMake(x*blockSize,(blocksHigh * blockSize) - y*blockSize);
                    block.scale = 1;
                    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(block.size.width, block.size.height)];
                    block.physicsBody.dynamic = NO;
                    block.physicsBody.allowsRotation = NO;
                    block.physicsBody.usesPreciseCollisionDetection = YES;
                    block.physicsBody.affectedByGravity = NO;
                    block.physicsBody.contactTestBitMask = 1;
                    
                    [_blocks addObject:block];
                    [self addChild:block];
                }
            }
        }
    }
    
    [self makeAppWindowOpaque];
    if (_hardcodeBlocks) {
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
        
        for (int i = 0; i < numBlocks/2; i++) {
            SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
            block.size = CGSizeMake(blockSize, blockSize);
            block.position = CGPointMake(location.x + ((i*blockSize)-((numBlocks/2)*blockSize)),location.y + (blockSize*4));
            block.scale = 1;
            
            block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
            block.physicsBody.dynamic = NO;
            block.physicsBody.allowsRotation = NO;
            block.physicsBody.usesPreciseCollisionDetection = YES;
            block.physicsBody.affectedByGravity = NO;
            block.physicsBody.contactTestBitMask = 1;
            
            /*
            SKTexture *walkLeft1 = [SKTexture textureWithImageNamed:@"player-jumping-left"];
            SKTexture *walkLeft2 = [SKTexture textureWithImageNamed:@"player-running-1-left"];
            SKAction *walkLeft = [SKAction animateWithTextures:@[walkLeft1, walkLeft2] timePerFrame:0.3];
            
            SKAction *walkLeftAction = [SKAction repeatActionForever:walkLeft];
            [block runAction:walkLeftAction withKey:@"walkLeft"];
            block.speed = 0;
            */
            
            [_blocks addObject:block];
            [self addChild:block];
        }
    }
}

- (void) renderPlayerPosition {
    int xDelta = 0;
    int yDelta = 0;
    
    int deltaChange = 1.7;
    
    if (_upPressed) {
        if (!_isJumping) {
            _isJumping = YES;
            [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, 1.5f) atPoint:_sprite.position];
            if (_isFacingLeft) {
                [self changeSpriteTexture:@"player-jumping-left"];
            } else {
                [self changeSpriteTexture:@"player-jumping-right"];
            }
        }
    } else if (_downPressed) {
        yDelta = -deltaChange;
    }
    
    if (_rightPressed) {
        _isFacingLeft = NO;
        if (!_isJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-right",_animationTicker]];
        }
        xDelta = +deltaChange;
    } else if (_leftPressed) {
        _isFacingLeft = YES;
        if (!_isJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-left",_animationTicker]];
        }
        xDelta = -deltaChange;
    }
    
    if (!_upPressed && !_downPressed && !_rightPressed && !_leftPressed) {
        if (_isFacingLeft) {
            [self changeSpriteTexture:@"player-standing-left"];
        } else {
            [self changeSpriteTexture:@"player-standing-right"];
        }
    }
    
    CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
    _sprite.position = desiredPosition;
    
    //_sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx + xDelta,_sprite.physicsBody.velocity.dy + yDelta);
}

- (void)changeSpriteTexture:(NSString*)textureName {
    if (![_sprite.texture.description isEqualToString:textureName]) {
        [_sprite setTexture:[SKTexture textureWithImageNamed:textureName]];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    _isJumping = NO;
    
    SKPhysicsBody *playerBody = contact.bodyA;
    SKPhysicsBody *blockBody  = contact.bodyB;
    
    if (contact.bodyB.node.physicsBody.contactTestBitMask == 0) {
        playerBody = contact.bodyB;
        blockBody = contact.bodyB;
    }
    
    if ((playerBody.node.position.y < contact.contactPoint.y) && (blockBody.node.position.y > contact.contactPoint.y)) {
        [playerBody applyImpulse:CGVectorMake(0.0f, -0.4f) atPoint:playerBody.node.position];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           [blockBody.node removeFromParent];
        });

        //blockBody.node.speed = 1;
    }
}

- (void) update:(CFTimeInterval)currentTime {
    _frameCount++;
    
    if (_frameCount == INT_MAX) {
        _frameCount = 0;
    }
    
    if ((_frameCount % 4) == 0) {
        _animationTicker++;
        if (_animationTicker > 3) {
            _animationTicker = 1;
        }
    }
    
    [self renderPlayerPosition];
}

@end
