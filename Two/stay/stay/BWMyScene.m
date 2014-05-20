//
//  BWMyScene.m
//  stay
//
//  Created by jins on 14-5-20.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import "BWMyScene.h"
#import "BWBackground.h"

@interface BWMyScene() <SKPhysicsContactDelegate>

@property (nonatomic, strong) BWBackground *bgManager;
@property (nonatomic, strong) SKSpriteNode *ball;
@property (nonatomic, assign) CFTimeInterval lastUpdateTimeInterval;

@end

@implementation BWMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.physicsWorld.contactDelegate = self;
        self.backgroundColor = [UIColor whiteColor];
        
        self.bgManager = [[BWBackground alloc] init];
        SKSpriteNode *bg0 = [self.bgManager createBgNode:YES];
        bg0.position = CGPointZero;
        [self addChild:bg0];
        
        SKSpriteNode *bg1 = [self.bgManager createBgNode:NO];
        bg1.position = CGPointMake(0, bg0.size.height);;
        [self addChild:bg1];
        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(20, 20)];
        ball.position = CGPointMake(self.size.width/2, 50);
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        ball.physicsBody.categoryBitMask = kBallBitMask;
        ball.physicsBody.collisionBitMask = 0;
        ball.physicsBody.contactTestBitMask = kBackgroundBitMask;
        ball.physicsBody.affectedByGravity = NO;
        [self addChild:ball];

        self.ball = ball;
        
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = self.ball.position;
    [self.ball setPosition:CGPointMake(position.x + translation.x, position.y)];
}

- (void)gameOver {
    NSLog(@"game over");
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kBallBitMask && contact.bodyB.categoryBitMask == kBackgroundBitMask) {
        [self gameOver];
    } else if (contact.bodyB.categoryBitMask == kBallBitMask && contact.bodyA.categoryBitMask == kBackgroundBitMask) {
        [self gameOver];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
    }
    
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (id)node;
        bg.position = CGPointMake(bg.position.x, bg.position.y - 80 * timeSinceLast);
        if (bg.position.y <= -bg.size.height) {
            /*int random = 0;
            while (random == 0) {
                random = arc4random_uniform((u_int32_t)24);
            }
            NSLog(@"random: %d", random);
            SKTexture *texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"path%d", random]];
            bg.texture = texture;*/
            bg.position = CGPointMake(bg.position.x, bg.position.y+ bg.size.height *2);
        }
    }];
}

@end
