//
//  ProgressHUD.m
//  EcreationsApp
//
//  Created by Jithin on 18/03/14.
//  Copyright (c) 2014 ecreations. All rights reserved.
//

#import "ProgressHUD.h"

@implementation ProgressHUD
@synthesize HUD;

+ (id)sharedFetchManager {
    static ProgressHUD *sharedFetchManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFetchManager = [[self alloc] init];
    });
    return sharedFetchManager;
}

/**********************************
 *
 *      MBProgressHUD
 *
 **********************************/
-(void)showHudProgress:(UIView *)view
{
    [self hideHudProgress];
    HUD=[[MBProgressHUD alloc] initWithView:view];
    HUD.labelText=@"Loading....";
    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:13.0];
    [HUD show:YES];
    [view addSubview:HUD];
}

-(void)showHudProgressWithText:(NSString *)text withView:(UIView *)view
{
    //[self hideHudProgress];
    [self hideHudProgressFromSuperView:view];
    //UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    //[MBProgressHUD hideAllHUDsForView:window animated:YES];
    HUD=[[MBProgressHUD alloc] initWithView:view];
    //HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    HUD.labelText=text;
    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:13.0];
    [HUD show:YES];
    [view addSubview:HUD];
}

-(void)showHudProgressWithTextForTabbarController:(NSString *)text withView:(UITabBarController *)view
{
    //[self hideHudProgress];
    [self hideHudProgressFromSuperViewWithTabbar:view];
    //UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    //[MBProgressHUD hideAllHUDsForView:window animated:YES];
    HUD=[[MBProgressHUD alloc] initWithView:view.view];
    //HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    HUD.labelText=text;
    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:13.0];
    [HUD show:YES];
    [view.view addSubview:HUD];
}


-(void)hideHudProgress
{
    if (HUD) {
        [HUD removeFromSuperview];
        HUD=nil;
    }
    
}

-(void)hideHudProgressFromSuperView:(UIView *)view
{
    if (HUD) {
        [MBProgressHUD hideAllHUDsForView:view animated:NO];
        [HUD removeFromSuperview];
        HUD=nil;
    }
}

-(void)hideHudProgressFromSuperViewWithTabbar:(UITabBarController *)tabView
{
    if (HUD) {
        [MBProgressHUD hideAllHUDsForView:tabView.view animated:NO];
        [HUD removeFromSuperview];
        HUD=nil;
    }
}

-(void)showHudProgressWithDownloadRate:(UIView *)view
{
    [self hideHudProgress];
    HUD=[[MBProgressHUD alloc] initWithView:view];
    HUD.labelFont=[UIFont fontWithName:@"Helvetica" size:13.0];
    HUD.mode=MBProgressHUDModeDeterminate;
    HUD.labelText=@"Uploading";
    //HUD.detailsLabelText=@"1.0";
    [view addSubview:HUD];
    [HUD show:YES];
    HUD.removeFromSuperViewOnHide = YES;
}

-(void)showTextOnlyAndHide:(NSString *)message parentView:(UIView *)view
{
    [self hideHudProgress];
    HUD= [[MBProgressHUD alloc] initWithView:view];	
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = message;
	HUD.margin = 12.f;
	HUD.yOffset = 10.f;
    [HUD setLabelFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [HUD show:YES];
    [view addSubview:HUD];
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:1];
    
}

-(void)showTextOnlyAndHideForChat:(NSString *)message parentView:(UIView *)view
{
    [self hideHudProgress];
    HUD= [[MBProgressHUD alloc] initWithView:view];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = message;
	HUD.margin = 12.f;
	HUD.yOffset = -200.0f;
    [HUD setLabelFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [HUD show:YES];
    [view addSubview:HUD];
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:1];
}

-(void)showTextAfterSomeTimeAndHideForChat:(NSString *)message parentView:(UIView *)view
{
    [self hideHudProgress];
    HUD= [[MBProgressHUD alloc] initWithView:view];
	// Configure for text only and offset down
	HUD.mode = MBProgressHUDModeText;
	HUD.labelText = message;
	HUD.margin = 12.f;
	HUD.yOffset = -200.0f;
    [HUD setLabelFont:[UIFont fontWithName:@"Helvetica" size:13.0f]];
    [HUD show:YES];
    [view addSubview:HUD];
	HUD.removeFromSuperViewOnHide = YES;
	[HUD hide:YES afterDelay:2];
}

@end
