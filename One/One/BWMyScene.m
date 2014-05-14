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
#define UIColorFromRGB(r, g, b)                   \
    [UIColor colorWithRed : ((CGFloat)r) / 255.0f \
    green : ((CGFloat)g) / 255.0f                 \
    blue : ((CGFloat)b) / 255.0f                  \
    alpha : 1.0f]
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
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, strong) SKLabelNode *restartLabel;
@property (nonatomic, strong) SKLabelNode *startLabel;
@property (nonatomic, strong) SKLabelNode *titleLabel;
@property (nonatomic, strong) SKLabelNode *gameOverLabel;
@property (nonatomic, strong) SKLabelNode *scoreLabel;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) CGPoint lastPosition;
@end

@implementation BWMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self;
        self.isStart = YES;
        self.isEnd = NO;
        self.lastPosition = CGPointZero;
        
        self.backgroundColor = UIColorFromRGB(70, 200, 200);
        
        SKSpriteNode *circle = [SKSpriteNode spriteNodeWithImageNamed:@"circle"];
        circle.position = CGPointMake(self.size.width/2, self.size.height/2);
        circle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:150];
        circle.physicsBody.categoryBitMask = kCircleBitMask;
        circle.physicsBody.collisionBitMask = 0;
        circle.physicsBody.contactTestBitMask = kBallBitMask;
        circle.physicsBody.dynamic = NO;
        [self addChild:circle];
        
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:UIColorFromRGB(216, 91, 91) size:CGSizeMake(6, 50)];
        node.position = CGPointMake(self.size.width/2, self.size.height/2-150);
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
        
        SKAction *followTrack = [SKAction followPath:self.path asOffset:NO orientToPath:YES duration:1.5];
        
        self.action = [SKAction repeatActionForever:followTrack];
        [self.player runAction:self.action];
         CGPathRelease(self.path);
        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        ball.position = CGPointMake(self.size.width/2, self.size.height/2);
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        ball.physicsBody.affectedByGravity = NO;
        ball.physicsBody.categoryBitMask = kBallBitMask;
        ball.physicsBody.collisionBitMask = 0;
        ball.physicsBody.contactTestBitMask = kPlayerBitMask | kCircleBitMask;
        //ball.physicsBody.dynamic = NO;
        
        ball.physicsBody.linearDamping = 0.0;
        ball.physicsBody.angularDamping = 0.0;
        ball.physicsBody.restitution = 0;
        ball.physicsBody.dynamic = YES;
        ball.physicsBody.friction = 0.0;
        //ball.physicsBody.allowsRotation = NO;
        [self addChild:ball];
        self.ball = ball;
        
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
        titleLabel.fontSize = 30.0f;
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        titleLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 50);
        titleLabel.text = @"Tango Ball";
        [self addChild:titleLabel];
        self.titleLabel = titleLabel;
        
        SKLabelNode *tapStart = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
        tapStart.fontSize = 20;
        tapStart.text = @"Tap To Go";
        tapStart.fontColor = [UIColor whiteColor];
        tapStart.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        tapStart.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        tapStart.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
        [self addChild:tapStart];
        [tapStart runAction:[SKAction repeatActionForever:
                        [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                             [SKAction fadeInWithDuration:1.0]]]
                        ]];
        self.startLabel = tapStart;

        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isStart) {
        [self.titleLabel removeFromParent];
        [self.startLabel removeFromParent];
        
        self.lastPosition = CGPointZero;
        
        self.score = 0;
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
        scoreLabel.fontSize = 30.0f;
        scoreLabel.fontColor = [SKColor whiteColor];
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        scoreLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 200);
        [self addChild:scoreLabel];
        self.scoreLabel = scoreLabel;
        
        SKAction *showScoreAction = [SKAction runBlock:^{
            self.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
        }];
        SKAction *waitAction = [SKAction waitForDuration:0.2];
        [self.scoreLabel runAction:[SKAction repeatActionForever:[SKAction sequence:@[showScoreAction, waitAction]]]];
        
        [self.ball.physicsBody applyImpulse:CGVectorMake(0, -3)];
        //[self.ball runAction:[SKAction moveTo:CGPointMake(self.size.width/2, self.size.height/2-160) duration:0.5]];
        self.isStart = NO;
    }
    if (self.isEnd) {
        self.isEnd = NO;
        [self.restartLabel removeFromParent];
        [self.gameOverLabel removeFromParent];
        
        SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
        titleLabel.fontSize = 30.0f;
        titleLabel.fontColor = [SKColor whiteColor];
        titleLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        titleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        titleLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 50);
        titleLabel.text = @"Tango Ball";
        [self addChild:titleLabel];
        self.titleLabel = titleLabel;
        
        SKLabelNode *tapStart = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
        tapStart.fontSize = 20;
        tapStart.text = @"Tap To Go";
        tapStart.fontColor = [UIColor whiteColor];
        tapStart.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        tapStart.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        tapStart.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
        [self addChild:tapStart];
        [tapStart runAction:[SKAction repeatActionForever:
                             [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                                  [SKAction fadeInWithDuration:1.0]]]
                             ]];
        self.startLabel = tapStart;

        
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
        ball.position = CGPointMake(self.size.width/2, self.size.height/2);
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
        ball.physicsBody.affectedByGravity = NO;
        ball.physicsBody.categoryBitMask = kBallBitMask;
        ball.physicsBody.collisionBitMask = 0;
        ball.physicsBody.contactTestBitMask = kPlayerBitMask | kCircleBitMask;
        [self addChild:ball];
        self.ball = ball;
        self.isStart = YES;
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
    self.action = [SKAction repeatActionForever:[SKAction followPath:self.path asOffset:NO orientToPath:YES duration:1.5]];
    [self.player runAction:self.action];
    CGPathRelease(self.path);
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    
    if (contact.bodyA.categoryBitMask == kPlayerBitMask && contact.bodyB.categoryBitMask == kBallBitMask) {
        
        
        CGFloat dx = fabs(contact.contactPoint.x - self.lastPosition.x);
        CGFloat dy = fabs(contact.contactPoint.y - self.lastPosition.y);
        self.lastPosition = contact.contactPoint;
        if (dx < 20 || dy < 20) {
            return;
        }
        
        
        
        //bodyB是球
        CGFloat desX = 0;
        CGFloat desY = 0;
        
        desX = self.size.width - self.player.position.x;
        desY = self.size.height - self.player.position.y;
        if (desX > self.size.width/2) {
            desX += 10;
        } else {
            desX -= 10;
        }
        if (desY > self.size.height/2) {
            desY += 10;
        } else {
            desY -= 10;
        }
        SKSpriteNode *ball = (id)contact.bodyB.node;
        [ball removeAllActions];
        [ball runAction:[SKAction moveTo:CGPointMake(desX, desY) duration:1]];
        self.score += 1;
        
        
        
        
    } else if (contact.bodyA.categoryBitMask == kBallBitMask && contact.bodyB.categoryBitMask == kPlayerBitMask) {
        //bodyA是球
        CGFloat dx = fabs(contact.contactPoint.x - self.lastPosition.x);
        CGFloat dy = fabs(contact.contactPoint.y - self.lastPosition.y);
        self.lastPosition = contact.contactPoint;
        if (dx < 20 || dy < 20) {
            return;
        }

        
        CGFloat desX = 0;
        CGFloat desY = 0;
        
        desX = self.size.width - self.player.position.x;
        desY = self.size.height - self.player.position.y;
        if (desX > self.size.width/2) {
            desX += 10;
        } else {
            desX -= 10;
        }
        if (desY > self.size.height/2) {
            desY += 10;
        } else {
            desY -= 10;
        }
        SKSpriteNode *ball = (id)contact.bodyA.node;
        [ball removeAllActions];
        [ball runAction:[SKAction moveTo:CGPointMake(desX, desY) duration:1]];
        self.score += 1;
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == kCircleBitMask && contact.bodyB.categoryBitMask == kBallBitMask) {
        [self gameOver];
        return;
    }
    if (contact.bodyA.categoryBitMask == kBallBitMask && contact.bodyB.categoryBitMask == kCircleBitMask) {
        [self gameOver];
        return;
    }
}

- (void)gameOver
{
    NSLog(@"game over");
    [self.delegate sceneGameEnd];
    [self.ball removeFromParent];
    //[self.player removeAllActions];
    self.isEnd = YES;
    
    [self.scoreLabel removeFromParent];
    
    //SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"CaviarDreams"];
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
    gameOverLabel.fontSize = 30.0f;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    gameOverLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    gameOverLabel.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 50);
    gameOverLabel.text = @"GAME OVER";
    [self addChild:gameOverLabel];
    self.gameOverLabel = gameOverLabel;
    
    SKLabelNode *tap = [SKLabelNode labelNodeWithFontNamed:@"Origin-Regular"];
    tap.fontSize = 20;
    tap.text = @"Tap To Restart";
    tap.fontColor = [UIColor whiteColor];
    tap.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    tap.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    tap.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 100);
    [self addChild:tap];
    [tap runAction:[SKAction repeatActionForever:
                    [SKAction sequence:@[[SKAction fadeOutWithDuration:1.0],
                                         [SKAction fadeInWithDuration:1.0]]]
                    ]];
    self.restartLabel = tap;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
