//
//  BWViewController.m
//  One
//
//  Created by jins on 14-5-13.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import "BWViewController.h"
#import "BWMyScene.h"
#import "GADInterstitial.h"

@interface BWViewController() <BWMySceneDelegate, GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, assign) int showTimes;
@end

@implementation BWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showTimes = 1;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.adUnitID = @"a153466fdba92fc";
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];

    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        //skView.showsFPS = YES;
        //skView.showsNodeCount = YES;
        //skView.showsPhysics = YES;
        
        // Create and configure the scene.
        BWMyScene * scene = [BWMyScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        scene.delegate = self;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"fail");
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"suc");
    //[self showInterstitial];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    //[self preloadRequest];
}

- (void)showInterstitial{
    if (self.interstitial.isReady) {
        NSLog(@"ready");
        [self.interstitial presentFromRootViewController:self];
    } else {
        //[self preloadRequest];
    }
}

- (void)sceneGameEnd
{
    if (self.showTimes % 5 == 0) {
        [self showInterstitial];
    } else {
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        shake.duration = 0.05;
        shake.repeatCount = 4;
        shake.autoreverses = YES;
        shake.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x - 4.0, self.view.center.y)];
        shake.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x + 4.0, self.view.center.y)];
        [[self.view layer] addAnimation:shake forKey:@"position"];
    }
    self.showTimes++;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
