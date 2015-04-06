//
//  GameScene.m
//  TestGame
//
//  Created by Aaron Randall on 05/04/2015.
//  Copyright (c) 2015 Aaron Randall. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    SKSpriteNode *_sprite;
    NSMutableArray *_blocks;
    BOOL _keyPressed;
    int _direction;
}

-(void)keyDown:(NSEvent *)event {
    _keyPressed = YES;
    
    switch([event keyCode]) {
        case 126:
            _direction = 1;
            break;
        case 125:
            _direction = 2;
            break;
        case 124:
            _direction = 3;
            break;
        case 123:
            _direction = 4;
            break;
        default:
            break;
    }
}

-(void)keyUp:(NSEvent *)theEvent {
    _keyPressed = NO;
}

-(void)mouseDown:(NSEvent *)theEvent {
    self.physicsWorld.gravity = CGVectorMake(0, -10);
    
    CGPoint location = [theEvent locationInNode:self];
    _sprite = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    _sprite.position = CGPointMake(location.x, location.y + 230);
    _sprite.scale = 1;
    _sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sprite.size];
    _sprite.physicsBody.allowsRotation = NO;
    _sprite.physicsBody.angularVelocity = 0.0f;
    _sprite.physicsBody.angularDamping = 0.0f;
    _sprite.physicsBody.dynamic = YES;
    [self addChild:_sprite];
    
    for (int i = 0; i < 5; i++) {
        SKSpriteNode *block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
        block = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
        block.position = CGPointMake(location.x + (block.size.width * i), location.y);
        block.scale = 1;
        block.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:block.size];
        block.physicsBody.dynamic = NO;
        block.physicsBody.allowsRotation = NO;
        block.physicsBody.usesPreciseCollisionDetection = YES;
        block.physicsBody.affectedByGravity = NO;
        
        [_blocks addObject:block];
        [self addChild:block];
    }
    
    
    // 3
    //_sprite.physicsBody.allowsRotation = NO;
    // 4
    //_sprite.physicsBody.restitution = 1.0f;
    //_sprite.physicsBody.friction = 0.0f;
    //_sprite.physicsBody.angularDamping = 0.0f;
    //_sprite.physicsBody.linearDamping = 0.0f;
    //SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    //[_sprite runAction:[SKAction repeatActionForever:action]];
}

-(void)renderPlayerPosition {
    if (_keyPressed) {
        int xDelta = 0;
        int yDelta = 0;
        
        switch (_direction) {
            case 1:
                [_sprite.physicsBody applyImpulse:CGVectorMake(0.0f, 2.0f) atPoint:_sprite.position];
                break;
            case 2:
                yDelta = -5;
                break;
            case 3:
                xDelta = +5;
                break;
            case 4:
                xDelta = -5;
                break;
            default:
                break;
        }
        
        CGPoint desiredPosition = CGPointMake(_sprite.position.x + xDelta, _sprite.position.y + yDelta);
        _sprite.position = desiredPosition;
        
       // _sprite.physicsBody.velocity = CGVectorMake(_sprite.physicsBody.velocity.dx + xDelta,_sprite.physicsBody.velocity.dy + yDelta);
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self renderPlayerPosition];
}

@end
