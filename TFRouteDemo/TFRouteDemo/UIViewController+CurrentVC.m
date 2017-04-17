//
//  UIViewControlleradd.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/16.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "UIViewController+CurrentVC.h"

@implementation UIViewController (CurrentVC)

+ (UIViewController *)getCurrentVC{
    
    UIViewController *result = nil;
    
    // 找到当前window
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];// iOS 9以前可以用[[UIApplication sharedApplication] keyWindow];获取，但iOS 9以后已经获取不到了，需要用这种方式获取
    
    //app默认windowLevel是UIWindowLevelNormal，如果不是，找到UIWindowLevelNormal的
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    //
    result = window.rootViewController;
    
    //    如果是present上来的appRootVC.presentedViewController 不为nil
    if (result.presentedViewController) {
        result = result.presentedViewController;// present出来的ViewContrller才是最前面的ViewController
    }
    
    // UITabBarController 包含 UINavigationController 或 UIViewController 的情况
    if ([result isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)result;
        result = tabbar.selectedViewController ; //上下两种写法都行
//        result = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];

        if ([result isKindOfClass:[UINavigationController class]]){
            UINavigationController *nav = (UINavigationController *)result;
            result = nav.topViewController;//上下两种写法都行
            
//        UIViewController * nav = (UIViewController *)result;
//        result = nav.childViewControllers.lastObject;
        }

    }
    
    // UINavigationController 包含 UITabBarController 或 UIViewController 的情况
    if ([result isKindOfClass:[UINavigationController class]]){
        UINavigationController *nav = (UINavigationController *)result;
        result = nav.topViewController;//上下两种写法都行
        
//        UIViewController * nav = (UIViewController *)result;
//        result = nav.childViewControllers.lastObject;
        
        if ([result isKindOfClass:[UITabBarController class]]){
            UITabBarController * tabbar = (UITabBarController *)result;
            result = tabbar.selectedViewController ; //上下两种写法都行
//        result = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        }
    }
    
    return result;
}

@end
