//
//  BWBackground.m
//  stay
//
//  Created by jins on 14-5-20.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import "BWBackground.h"

@implementation BWBackground

- (SKSpriteNode *)createBgNode:(BOOL)isStartNode
{
    int index = 0;
    if (!isStartNode) {
        //index = [self createIndex];
        index = 1;
    }
    SKTexture * texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"path%d", index]];
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithTexture:texture];
    bg.anchorPoint = CGPointZero;
    bg.name = @"background";
    bg.physicsBody = [self createPhysicsBody:index];
    bg.physicsBody.dynamic = NO;
    bg.physicsBody.categoryBitMask = kBackgroundBitMask;
    bg.physicsBody.collisionBitMask = 0;
    bg.physicsBody.contactTestBitMask = kBallBitMask;
    return bg;
}

- (int)createIndex
{
    int random = 0;
    while (random == 0) {
        random = arc4random_uniform((u_int32_t)24);
    }
    return random;
}

- (SKPhysicsBody *)createPhysicsBody:(int)index
{
    SKPhysicsBody *body;
    UIBezierPath* leftPath = [UIBezierPath bezierPath];
    UIBezierPath* rightPath = [UIBezierPath bezierPath];
    if (index == 0) {
        [leftPath moveToPoint:CGPointMake(2, 164)];
        [leftPath addLineToPoint:CGPointMake(67, 256)];
        [leftPath addLineToPoint:CGPointMake(96, 326)];
        [leftPath addLineToPoint:CGPointMake(120, 416)];
        [leftPath addLineToPoint:CGPointMake(133, 512)];
        
        [rightPath moveToPoint:CGPointMake(318, 163)];
        [rightPath addLineToPoint:CGPointMake(262, 239)];
        [rightPath addLineToPoint:CGPointMake(237, 290)];
        [rightPath addLineToPoint:CGPointMake(212, 360)];
        [rightPath addLineToPoint:CGPointMake(196, 427)];
        [rightPath addLineToPoint:CGPointMake(186, 501)];
        [rightPath addLineToPoint:CGPointMake(183, 566)];
        
    }
    
    if (index == 1) {
        [leftPath moveToPoint:CGPointMake(135, 1)];
        [leftPath addLineToPoint:CGPointMake(135, 72)];
        [leftPath addLineToPoint:CGPointMake(18, 235)];
        [leftPath addLineToPoint:CGPointMake(22, 260)];
        [leftPath addLineToPoint:CGPointMake(240, 336)];
        [leftPath addLineToPoint:CGPointMake(139, 476)];
        [leftPath addLineToPoint:CGPointMake(135, 488)];
        [leftPath addLineToPoint:CGPointMake(135, 566)];
        
        [rightPath moveToPoint:CGPointMake(182, 1)];
        [rightPath addLineToPoint:CGPointMake(182, 82)];
        [rightPath addLineToPoint:CGPointMake(78, 230)];
        [rightPath addLineToPoint:CGPointMake(289, 303)];
        [rightPath addLineToPoint:CGPointMake(302, 328)];
        [rightPath addLineToPoint:CGPointMake(184, 494)];
        [rightPath addLineToPoint:CGPointMake(182, 565)];

    }
    SKPhysicsBody *bodyLeft = [SKPhysicsBody bodyWithEdgeChainFromPath:leftPath.CGPath];
    bodyLeft.categoryBitMask = kBackgroundBitMask;
    bodyLeft.collisionBitMask = 0;
    bodyLeft.contactTestBitMask = kBallBitMask;
    SKPhysicsBody *bodyRight = [SKPhysicsBody bodyWithEdgeChainFromPath:rightPath.CGPath];
    body = [SKPhysicsBody bodyWithBodies:@[bodyLeft, bodyRight]];
    return body;
}

@end
