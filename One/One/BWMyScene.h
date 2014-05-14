//
//  BWMyScene.h
//  One
//

//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol BWMySceneDelegate <NSObject>

- (void)sceneGameEnd;

@end

@interface BWMyScene : SKScene

@property (nonatomic, weak) id<BWMySceneDelegate> delegate;

@end
