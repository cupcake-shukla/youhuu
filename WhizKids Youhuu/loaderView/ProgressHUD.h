//
//  ProgressHUD.h
//  EcreationsApp
//
//  Created by Jithin on 18/03/14.
//  Copyright (c) 2014 ecreations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ProgressHUD : NSObject<MBProgressHUDDelegate>
{
    MBProgressHUD               *HUD;
}

@property(nonatomic, retain)    MBProgressHUD               *HUD;

+(id)sharedFetchManager;
-(void)showHudProgress:(UIView *)view;
-(void)showHudProgressWithText:(NSString *)text withView:(UIView *)view;
-(void)hideHudProgress;
-(void)showHudProgressWithDownloadRate:(UIView *)view;
-(void)showTextOnlyAndHide:(NSString *)message parentView:(UIView *)view;
-(void)showTextOnlyAndHideForChat:(NSString *)message parentView:(UIView *)view;
-(void)showTextAfterSomeTimeAndHideForChat:(NSString *)message parentView:(UIView *)view;
-(void)showHudProgressWithTextForTabbarController:(NSString *)text withView:(UITabBarController *)view;
-(void)hideHudProgressFromSuperViewWithTabbar:(UITabBarController *)tabView;
@end
