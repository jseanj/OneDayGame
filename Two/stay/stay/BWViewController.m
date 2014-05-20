//
//  BWViewController.m
//  stay
//
//  Created by jins on 14-5-20.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import "BWViewController.h"
#import "BWMyScene.h"
#import "GADInterstitial.h"
#import "WXApi.h"
#define BUFFER_SIZE 1024 * 100

@interface BWViewController() <BWMySceneDelegate, GADInterstitialDelegate>
@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, assign) int showTimes;
@end

@implementation BWViewController

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
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
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
        [self shakeScreen];
    }
}

- (void)sceneGameEnd
{
    if (self.showTimes % 5 == 0) {
        [self showInterstitial];
    } else {
        [self shakeScreen];
    }
    self.showTimes++;
}

- (void)shakeScreen
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    shake.duration = 0.05;
    shake.repeatCount = 4;
    shake.autoreverses = YES;
    shake.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x - 4.0, self.view.center.y)];
    shake.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x + 4.0, self.view.center.y)];
    [[self.view layer] addAnimation:shake forKey:@"position"];
}

- (void)sendWeixin:(int)score
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [NSString stringWithFormat:@"我刚在Stay Ball里得到%d分，小伙伴们，快来挑战我吧！", score];
    message.description = [NSString stringWithFormat:@"我刚在Stay Ball里得到%d分，小伙伴们，快来挑战我吧！", score];
    [message setThumbImage:[UIImage imageNamed:@"wechat"]];
    
    WXAppExtendObject *ext = [WXAppExtendObject object];
    ext.extInfo = @"<xml>extend info</xml>";
    ext.url = @"https://itunes.apple.com/cn/app/2048/id840919914?mt=8";
    
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    ext.fileData = data;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
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
