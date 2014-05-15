//
//  BWAppDelegate.h
//  One
//
//  Created by jins on 14-5-13.
//  Copyright (c) 2014年 BlackWater. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface BWAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
