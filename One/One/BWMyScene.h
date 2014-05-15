//
//  BWMyScene.h
//  One
//

//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol BWMySceneDelegate <NSObject>

- (void)sceneGameEnd;
- (void)sendWeixin:(int)score;

@end

@interface BWMyScene : SKScene

@property (nonatomic, weak) id<BWMySceneDelegate> delegate;

@end
