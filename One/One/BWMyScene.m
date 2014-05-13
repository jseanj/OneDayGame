//
//  BWMyScene.m
//  One
//
//  Created by jins on 14-5-13.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import "BWMyScene.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
static const uint32_t kPlayerBitMask =  0x1 << 0;
static const uint32_t kBallBitMask   =  0x1 << 1;
static const uint32_t kCircleBitMask   =  0x1 << 2;
@interface BWMyScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, strong) SKAction *action;
@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, assign) BOOL isClockWise;
@property (nonatomic, assign) BOOL isStart;
@end

@implementation BWMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self;
        self.isStart = YES;
        
        SKSpriteNode *circle = [SKSpriteNode spriteNodeWithImageNamed:@"circle"];
        circle.position = CGPointMake(self.size.width/2, self.size.height/2);
        circle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:150];
        circle.physicsBody.categoryBitMask = kCircleBitMask;
        circle.physicsBody.collisionBitMask = 0;
        circle.physicsBody.contactTestBitMask = kBallBitMask;
        circle.physicsBody.dynamic = NO;
        [self addChild:circle];
        
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(6, 50)];
        //node.position = CGPointMake(self.size.width/2, self.size.height/2);
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size];
        node.physicsBody.affectedByGravity = NO;
        node.physicsBody.categoryBitMask = kPlayerBitMask;
        node.physicsBody.collisionBitMask = 0;
        node.physicsBody.contactTestBitMask = kBallBitMask;
        //node.physicsBody.dynamic = NO;
        [self addChild:node];
        
        self.player = node;
        self.path = CGPathCreateMutable();
        
        CGPathAddArc(self.path, NULL, self.size.width/2, self.size.height/2, 150.f, -M_PI_2, -M_PI_2*5, YES);
        self.isClockWise = YES;
        
        SKAction *followTrack = [SKAction followPath:self.path asOffset:NO orientToPath:YES duration:3.0];
        
        self.action = [SKAction repeatActionForever:followTrack];
        [self.player runAction:[SKAction sequence:@[[SKAction waitForDuration:1], self.action]]];
         CGPathRelease(self.path);
        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(20, 20)];
        ball.position = CGPointMake(self.size.width/2, self.size.height/2);
        ball.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ball.size];
        ball.physicsBody.affectedByGravity = NO;
        ball.physicsBody.categoryBitMask = kBallBitMask;
        ball.physicsBody.collisionBitMask = 0;
        ball.physicsBody.contactTestBitMask = kPlayerBitMask | kCircleBitMask;
        /*ball.physicsBody.linearDamping = 0.0;
        ball.physicsBody.angularDamping = 0.0;
        ball.physicsBody.restitution = 0.4;
        ball.physicsBody.dynamic = YES;
        ball.physicsBody.friction = 0.0;
        ball.physicsBody.allowsRotation = NO;*/
        [self addChild:ball];
        self.ball = ball;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isStart) {
        [self.ball.physicsBody applyImpulse:CGVectorMake(0, -2)];
        self.isStart = NO;
    }
    
    
    [self.player removeAllActions];
    self.action = nil;
    self.path = CGPathCreateMutable();
    CGFloat start = 0;
    CGFloat end = 0;
    float angle = atan2f(self.player.position.y - self.size.height/2, self.player.position.x - self.size.width/2);

    if (self.isClockWise) {
        //如果当前是顺时针，则开始逆时针，end-start = M_PI * 2
        start = angle;
        end = M_PI * 2 + start;
    } else {
        //如果当前是逆时针，则开始顺时针，end-start = -M_PI * 2
        start = angle;
        end = -M_PI * 2 + start;
    }
    //NSLog(@"start degree: %f", RADIANS_TO_DEGREES(start));
    //NSLog(@"end degree: %f", RADIANS_TO_DEGREES(end));

    if (self.isClockWise) {
        CGPathAddArc(self.path, NULL, self.size.width/2, self.size.height/2, 150.f, start, end, NO);
        self.isClockWise = NO;
    } else {
        CGPathAddArc(self.path, NULL, self.size.width/2, self.size.height/2, 150.f, start, end,YES);
        self.isClockWise = YES;
    }
    self.action = [SKAction repeatActionForever:[SKAction followPath:self.path asOffset:NO orientToPath:YES duration:2.0]];
    [self.player runAction:self.action];
    CGPathRelease(self.path);
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kCircleBitMask && contact.bodyB.categoryBitMask == kBallBitMask) {
        [self gameOver];
        return;
    }
    if (contact.bodyA.categoryBitMask == kBallBitMask && contact.bodyB.categoryBitMask == kCircleBitMask) {
        [self gameOver];
        return;
    }
    
    CGFloat vectorX = -(self.player.position.x - self.size.width/2)/150;
    CGFloat vectorY = -(self.player.position.y - self.size.height/2)/150;
    if (vectorX > 0) {
        vectorX += 2;
    } else {
        vectorX -= 2;
    }
    if (vectorY > 0) {
        vectorY += 2;
    } else {
        vectorY -= 2;
    }
    if (contact.bodyA.categoryBitMask == kPlayerBitMask && contact.bodyB.categoryBitMask == kBallBitMask) {
        //bodyB是球
        SKSpriteNode *ball = (id)contact.bodyB.node;
        NSLog(@"1. %f, %f", self.player.position.x - self.size.width/2, self.player.position.y - self.size.height/2);
        [ball.physicsBody applyImpulse:CGVectorMake(vectorX, vectorY)];
    } else if (contact.bodyA.categoryBitMask == kBallBitMask && contact.bodyB.categoryBitMask == kPlayerBitMask) {
        //bodyA是球
        NSLog(@"2. %f, %f", self.player.position.x - self.size.width/2, self.player.position.y - self.size.height/2);
        SKSpriteNode *ball = (id)contact.bodyA.node;
        [ball.physicsBody applyImpulse:CGVectorMake(vectorX, vectorY)];
    }
}

- (void)gameOver
{
    NSLog(@"game over");
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
