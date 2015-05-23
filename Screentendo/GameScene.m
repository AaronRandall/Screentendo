//
//  GameScene.m
//  Screentendo
//
//  Created by Aaron Randall on 09/05/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "GameScene.h"
#import "ImageStructureAnalyser.h"
#import "AppDelegate.h"
#import "Window.h"

@interface GameScene() <SKPhysicsContactDelegate>
@end

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    SKSpriteNode *_background;

    BOOL _leftPressed;
    BOOL _rightPressed;
    BOOL _upPressed;
    BOOL _downPressed;
    
    BOOL _playerSpriteIsJumping;
    BOOL _playerSpriteIsFacingLeft;

    int _frameCount;
    int _animationTicker;
}

typedef NS_ENUM(NSInteger, Direction) {
    Left  = 123,
    Right = 124,
    Up    = 126,
    Down  = 125
};

const int defaultBlockSize = 10;
const int statusBarHeight = 22;
const int physicsVelocityDampenerThreshold = 350;
const int physicsVelocityDampener = 200;
const bool hardcodeBlocks = NO;

const uint32_t playerCategory = 0x1 << 0;
const uint32_t blockCategory = 0x1 << 1;
const uint32_t blockDebrisCategory = 0x1 << 2;
const uint32_t noCategory = 0x1 << 3;

- (int)blockSize {
    if (!_blockSize) {
        _blockSize = defaultBlockSize;
    }

    return _blockSize;
}

#pragma mark -
#pragma mark User input

- (void)keyDown:(NSEvent *)event {
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

- (void)keyUp:(NSEvent *)event {
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

- (void)mouseDown:(NSEvent *)event {
    [self resetScene];
    [self makeAppWindowTransparent];

    if (hardcodeBlocks) {
        [self renderHardcodedSceneWithEvent:event];
    } else {
        [self renderSceneWithEvent:event];
    }
}

#pragma mark -
#pragma mark Window actions

- (void)makeAppWindowTransparent {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowTransparent];
}

- (void)makeAppWindowOpaque {
    [(AppDelegate*)[[NSApplication sharedApplication] delegate] makeWindowOpaque];
}

- (void)didChangeSize:(CGSize)oldSize {
    [self resetScene];
    [self makeAppWindowTransparent];
}

#pragma mark -
#pragma mark Drawing actions

- (void)renderSceneWithEvent:(NSEvent *)event {
    bool renderBackgroundAsBlocks = NO;
    bool fadeBackground = YES;

    NSImage *image = [Window croppedImageOfTopLevelWindow];

    [self renderBackgroundWithImage:image];
    [self makeAppWindowOpaque];

    [ImageStructureAnalyser blocksFromImage:image blockSize:self.blockSize blockCalculated:^(NSDictionary *imageBinaryBlock) {
        int x = [imageBinaryBlock[@"x"] intValue];
        int y = [imageBinaryBlock[@"y"] intValue];
        bool blockValue = [imageBinaryBlock[@"binaryValue"] boolValue];

        if (blockValue) {
            [self renderBlockSpriteAtPositionX:(x*self.blockSize) y:((self.view.frame.size.height + statusBarHeight) - y*self.blockSize)];
        } else {
            if (renderBackgroundAsBlocks) {
                [self renderBackgroundBlockSpriteAtPositionX:(x*self.blockSize) y:((self.view.frame.size.height + statusBarHeight) - y*self.blockSize)];
            }
        }
    } completion:^(NSArray *imageBinaryArray) {
        CGPoint location = [event locationInNode:self];

        [self setScenePhysics];
        [self renderCloudSpriteAtPositionX:self.frame.size.width/3.5 y:self.frame.size.height/1.2];
        [self renderCloudSpriteAtPositionX:self.frame.size.width/1.3 y:self.frame.size.height/1.1];
        [self renderPlayerSpriteAtPositionX:location.x y:location.y + 230];

        [_background removeFromParent];

        if (fadeBackground) {
            NSColor *transparentColor = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.00f];
            NSColor *blueColor = [NSColor colorWithCalibratedRed:0.480f green:0.480f blue:1.000f alpha:1.00f];

            SKSpriteNode *bg = [SKSpriteNode spriteNodeWithColor:transparentColor size:self.size];
            bg.position = CGPointMake(bg.size.width/2, bg.size.height/2);
            [self addChild:bg];
            SKAction *color = [SKAction colorizeWithColor:blueColor colorBlendFactor:0 duration:0.4f];
            [bg runAction:[SKAction repeatAction:[SKAction sequence:@[color]] count:1]];
        } else {
            self.backgroundColor = [NSColor colorWithCalibratedRed:0.480f green:0.480f blue:1.000f alpha:1.00f];
        }
    }];
}

- (void)renderHardcodedSceneWithEvent:(NSEvent *)event {
    CGPoint location = [event locationInNode:self];

    [self setScenePhysics];
    [self renderCloudSpriteAtPositionX:self.blockSize*4 y:self.frame.size.height/1.2];
    [self renderCloudSpriteAtPositionX:self.frame.size.width/1.5 y:self.frame.size.height/1.5];
    [self renderPlayerSpriteAtPositionX:location.x y:location.y + 230];

    int numBlocks = 20;
    for (int i = 0; i < numBlocks; i++) {
        [self renderBlockSpriteAtPositionX:location.x + ((i*self.blockSize)-((numBlocks/2)*self.blockSize)) y:location.y];
    }

    for (int i = 0; i < numBlocks/2; i++) {
        [self renderBlockSpriteAtPositionX:location.x + ((i*self.blockSize)-((numBlocks/2)*self.blockSize)) y:location.y + (self.blockSize*4)];
    }

    [self makeAppWindowOpaque];
    self.backgroundColor = [NSColor colorWithCalibratedRed:0.480f green:0.480f blue:1.000f alpha:1.00f];
}

- (void)renderBackgroundWithImage:(NSImage*)image {
    SKTexture *backgroundTexture = [SKTexture textureWithImage:image];
    _background = [SKSpriteNode spriteNodeWithTexture:backgroundTexture size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + statusBarHeight)];
    _background.position = (CGPoint) {CGRectGetMidX(self.view.frame), CGRectGetMidY(self.view.frame) + (statusBarHeight/2)};
    [self addChild:_background];
}

- (void)renderCloudSpriteAtPositionX:(int)x y:(int)y {
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    cloud.size = CGSizeMake(0, 0);
    cloud.zPosition = 0;
    cloud.position = CGPointMake(x, y);

    SKAction *expand = [SKAction resizeToWidth:self.blockSize*4 height:self.blockSize*3 duration:2.0f];
    expand.timingMode = SKActionTimingEaseOut;
    [cloud runAction:expand];

    [self addChild:cloud];
}

- (void)renderPlayerSpriteAtPositionX:(int)x y:(int)y {
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player-standing-right"];
    _sprite.size = CGSizeMake(self.blockSize, self.blockSize * 2);
    _sprite.position = CGPointMake(x, y);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_sprite.size.width, _sprite.size.height)];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    _sprite.physicsBody.categoryBitMask = playerCategory;
    _sprite.physicsBody.contactTestBitMask = blockCategory;
    _sprite.physicsBody.collisionBitMask = blockCategory;

    [self addChild:_sprite];
}

- (void)renderBlockSpriteAtPositionX:(int)x y:(int)y {
    SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
    block.size = CGSizeMake(0, 0);
    block.position = CGPointMake(x,y);
    block.scale = 1;
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.blockSize, self.blockSize)];
    block.physicsBody.dynamic = NO;
    block.physicsBody.allowsRotation = NO;
    block.physicsBody.usesPreciseCollisionDetection = YES;
    block.physicsBody.affectedByGravity = NO;
    block.physicsBody.categoryBitMask = blockCategory;
    block.physicsBody.contactTestBitMask = playerCategory;
    block.physicsBody.collisionBitMask = playerCategory;

    SKAction *expand = [SKAction resizeToWidth:self.blockSize height:self.blockSize duration:0.5f];
    expand.timingMode = SKActionTimingEaseOut;
    [block runAction:expand];

    [_blocks addObject:block];
    [self addChild:block];
}

- (void)renderBackgroundBlockSpriteAtPositionX:(int)x y:(int)y {
    SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"background-block"];
    block.size = CGSizeMake(0, 0);
    block.position = CGPointMake(x,y);
    block.scale = 1;
    block.physicsBody.dynamic = NO;
    block.physicsBody.allowsRotation = NO;
    block.physicsBody.usesPreciseCollisionDetection = NO;
    block.physicsBody.affectedByGravity = NO;

    SKAction *expand = [SKAction resizeToWidth:self.blockSize height:self.blockSize duration:0.5f];
    expand.timingMode = SKActionTimingEaseOut;
    [block runAction:expand];

    [self addChild:block];
}

- (void)renderPlayerPosition {
    int xDelta = 0;
    int yDelta = 0;

    int deltaChange = 1.7;

    NSDictionary* physicsRatios = @{[NSNumber numberWithInt:14]: @4.3f,
                                    [NSNumber numberWithInt:12]: @3.0f,
                                    [NSNumber numberWithInt:10]: @1.8f,
                                    [NSNumber numberWithInt:8]: @1.0f,
                                    [NSNumber numberWithInt:6]: @0.5f,
                                    };
    float jumpImpulse = [physicsRatios[[NSNumber numberWithInt:self.blockSize]] floatValue];

    if (_upPressed) {
        if (!_playerSpriteIsJumping) {
            _playerSpriteIsJumping = YES;
            [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, jumpImpulse) atPoint:_sprite.position];
            if (_playerSpriteIsFacingLeft) {
                [self changeSpriteTexture:@"player-jumping-left"];
            } else {
                [self changeSpriteTexture:@"player-jumping-right"];
            }
        }
    } else if (_downPressed) {
        yDelta = -deltaChange;
    }

    if (_rightPressed) {
        _playerSpriteIsFacingLeft = NO;
        if (!_playerSpriteIsJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-right",_animationTicker]];
        }
        xDelta = +deltaChange;
    } else if (_leftPressed) {
        _playerSpriteIsFacingLeft = YES;
        if (!_playerSpriteIsJumping) {
            [self changeSpriteTexture:[NSString stringWithFormat:@"player-running-%i-left",_animationTicker]];
        }
        xDelta = -deltaChange;
    }

    if (!_upPressed && !_downPressed && !_rightPressed && !_leftPressed) {
        if (_playerSpriteIsFacingLeft) {
            [self changeSpriteTexture:@"player-standing-left"];
        } else {
            [self changeSpriteTexture:@"player-standing-right"];
        }
    }

    CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
    _sprite.position = desiredPosition;
}

- (void)changeSpriteTexture:(NSString*)textureName {
    if (![_sprite.texture.description isEqualToString:textureName]) {
        [_sprite setTexture:[SKTexture textureWithImageNamed:textureName]];
    }
}

- (void)breakBlock:(SKNode*)block {
    SKSpriteNode *blockDebris = [SKSpriteNode spriteNodeWithImageNamed:@"block-debris"];
    blockDebris.size = CGSizeMake(self.blockSize/2, self.blockSize/2);
    blockDebris.position = block.position;
    blockDebris.scale = 1;

    blockDebris.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:blockDebris.size];
    blockDebris.physicsBody.dynamic = YES;
    blockDebris.physicsBody.allowsRotation = YES;
    blockDebris.physicsBody.usesPreciseCollisionDetection = NO;
    blockDebris.physicsBody.affectedByGravity = YES;
    blockDebris.zPosition = 100;
    blockDebris.physicsBody.categoryBitMask = blockDebrisCategory;
    blockDebris.physicsBody.contactTestBitMask = noCategory;
    blockDebris.physicsBody.collisionBitMask = noCategory;

    SKSpriteNode *debris1 = blockDebris.copy;
    SKSpriteNode *debris2 = blockDebris.copy;
    SKSpriteNode *debris3 = blockDebris.copy;
    SKSpriteNode *debris4 = blockDebris.copy;

    [self addChild:debris1];
    [self addChild:debris2];
    [self addChild:debris3];
    [self addChild:debris4];

    float xD = 0.03f;
    float y1D = 0.115f;
    float y2D = 0.065f;
    
    [debris1.physicsBody applyImpulse:CGVectorMake(xD, y1D) atPoint:blockDebris.position];
    [debris2.physicsBody applyImpulse:CGVectorMake(-xD, y1D) atPoint:blockDebris.position];
    [debris3.physicsBody applyImpulse:CGVectorMake(xD, y2D) atPoint:blockDebris.position];
    [debris4.physicsBody applyImpulse:CGVectorMake(-xD, y2D) atPoint:blockDebris.position];
    [block removeFromParent];
}

- (void)resetScene {
    [self removeAllChildren];
    [_blocks removeAllObjects];
}

- (void)update:(CFTimeInterval)currentTime {
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

#pragma mark -
#pragma mark Physics actions

- (void)setScenePhysics {
    self.physicsWorld.gravity = CGVectorMake(0, -3);
    self.physicsWorld.contactDelegate = self;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    _playerSpriteIsJumping = NO;

    SKPhysicsBody *playerBody = contact.bodyA;
    SKPhysicsBody *blockBody  = contact.bodyB;

    if (contact.bodyB.node.physicsBody.categoryBitMask == playerCategory) {
        playerBody = contact.bodyB;
        blockBody = contact.bodyA;
    }

    if ((playerBody.node.position.y < contact.contactPoint.y) && (blockBody.node.position.y > contact.contactPoint.y)) {
        [playerBody applyImpulse:CGVectorMake(0.0f, -0.4f) atPoint:playerBody.node.position];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self breakBlock:blockBody.node];
        });
    }
}

- (void)didSimulatePhysics {
    if (_sprite.physicsBody.velocity.dy > physicsVelocityDampenerThreshold) {
        _sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx, physicsVelocityDampener);
    }
}

@end
