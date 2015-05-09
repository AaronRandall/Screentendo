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

const int defaultBlockSize = 10;
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

- (void)resetScene {
    [self removeAllChildren];
    [_blocks removeAllObjects];
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
    NSImage *image = [Window croppedImageOfTopLevelWindow];
    [ImageStructureAnalyser binaryArrayFromImage:image blockSize:self.blockSize completion:^(NSArray *imageArray) {
        CGPoint location = [event locationInNode:self];
        
        [self setScenePhysics];
        [self renderCloudSpriteAtPositionX:self.blockSize*4 y:self.frame.size.height/1.2];
        [self renderCloudSpriteAtPositionX:self.frame.size.width/1.5 y:self.frame.size.height/1.5];
        [self renderPlayerSpriteAtPositionX:location.x y:location.y + 230];
        
        int blocksWide = (int)imageArray.count;
        int blocksHigh = (int)[(NSArray*)[imageArray objectAtIndex:0] count];
        
        for (int x = 0; x < blocksWide; x++) {
            for (int y = 0; y < blocksHigh; y++) {
                NSNumber *currentColor = imageArray[x][y];
                
                if ([currentColor isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    [self renderBlockSpriteAtPositionX:(x*self.blockSize) y:((blocksHigh * self.blockSize) - y*self.blockSize)];
                }
            }
        }
        
        [self makeAppWindowOpaque];
        self.backgroundColor = [NSColor colorWithCalibratedRed:0.480f green:0.480f blue:1.000f alpha:1.00f];
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

- (void)renderCloudSpriteAtPositionX:(int)x y:(int)y {
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud"];
    cloud.size = CGSizeMake(self.blockSize*4, self.blockSize*3);
    cloud.zPosition = 0;
    cloud.position = CGPointMake(x, y);
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
    block.size = CGSizeMake(self.blockSize, self.blockSize);
    block.position = CGPointMake(x,y);
    block.scale = 1;
    block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(block.size.width, block.size.height)];
    block.physicsBody.dynamic = NO;
    block.physicsBody.allowsRotation = NO;
    block.physicsBody.usesPreciseCollisionDetection = YES;
    block.physicsBody.affectedByGravity = NO;
    block.physicsBody.categoryBitMask = blockCategory;
    block.physicsBody.contactTestBitMask = playerCategory;
    block.physicsBody.collisionBitMask = playerCategory;
    
    [_blocks addObject:block];
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
        if (!_isJumping) {
            _isJumping = YES;
            [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, jumpImpulse) atPoint:_sprite.position];
            if (_isFacingLeft) {
                [self changeSpriteTexture:@"player-jumping-left"];
            } else {
                [self changeSpriteTexture:@"player-jumping-right"];
            }
        }
    } else if (_downPressed) {
        //yDelta = -deltaChange;
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
    
    [debris1.physicsBody applyImpulse:CGVectorMake(0.05f, 0.2f) atPoint:blockDebris.position];
    [debris2.physicsBody applyImpulse:CGVectorMake(-0.05f, 0.2f) atPoint:blockDebris.position];
    [debris3.physicsBody applyImpulse:CGVectorMake(0.05f, 0.1f) atPoint:blockDebris.position];
    [debris4.physicsBody applyImpulse:CGVectorMake(-0.05f, 0.1f) atPoint:blockDebris.position];
    [block removeFromParent];
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
    _isJumping = NO;
    
    SKPhysicsBody *playerBody = contact.bodyA;
    SKPhysicsBody *blockBody  = contact.bodyB;
    
    if (contact.bodyB.node.physicsBody.categoryBitMask == playerCategory) {
        playerBody = contact.bodyB;
        blockBody = contact.bodyA;
    }
    
    if ((playerBody.node.position.y < contact.contactPoint.y) && (blockBody.node.position.y > contact.contactPoint.y)) {
        [playerBody applyImpulse:CGVectorMake(0.0f, -0.4f) atPoint:playerBody.node.position];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Breaking block with data:");
            NSLog(@"Player position x,y=%f,%f", playerBody.node.position.x, playerBody.node.position.y);
            NSLog(@"Block position x,y=%f,%f", blockBody.node.position.x, blockBody.node.position.y);
            NSLog(@"Contact position x,y=%f,%f", contact.contactPoint.x, contact.contactPoint.y);
            [self breakBlock:blockBody.node];
        });
    }
}

- (void)didSimulatePhysics {
    if (_sprite.physicsBody.velocity.dy > 350) {
        NSLog(@"%f",_sprite.physicsBody.velocity.dy);
        NSLog(@"Dampening");
        _sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx,200);
    }
}

@end
