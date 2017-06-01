//
//  TFRouter.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/15.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "TFRouter.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "RouteDefaultViewController.h"


#define TFRouterErrorDomain @"TFRouterErrorDomain"

@interface TFRouter ()


@end

@implementation TFRouter

+ (instancetype)shared {
    NSLog(@"%s", __func__);
    static dispatch_once_t onceToken;
    static TFRouter *router;
    dispatch_once(&onceToken,^{
        router = [[TFRouter alloc] init];
        
        NSString *path =  [[NSBundle mainBundle] pathForResource:@"RoutingTable" ofType:@"plist"];
        router.routeTable = [NSDictionary dictionaryWithContentsOfFile:path];
        
        router.request = nil;
        router.response = nil;
        
    });
    
    return router;
}

- (void)returnError:(NSInteger)errcode localizedDescription:(NSString *)localizedDescription byCompletionBlock:(void(^)(NSError *error, TFRouteResponse *reponseData))completion
{
    NSLog(@"%s", __func__);
    if (localizedDescription == nil) {
        localizedDescription = @"未知错误";
    }
    NSLog(@"TFRouterError: [%ld] %@", errcode, localizedDescription);
    if (completion) {
        NSError *error = [NSError errorWithDomain:TFRouterErrorDomain code:errcode userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
        completion(error, nil);
    }
}



- (void)routeWithUrl:(NSString*)url completion:(void(^)(NSError *error, TFRouteResponse *reponseData))completion
{
    NSLog(@"%s", __func__);
    if (url == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
        return;
    }
    
    TFRouteRequest *request = [[TFRouteRequest alloc] initWithUrl:url];
    self.request = request;
    
    if (request == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
    }

    [self routeWithRequest:request completion:completion];
    
}

- (void)routeWithRequest:(TFRouteRequest*)request completion:(void(^)(NSError *error, TFRouteResponse *reponse))completion
{
    NSLog(@"%s", __func__);
    if (request == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
        return;
    }
    
    self.request = request;
    
    TFURLInfo *urlInfo = request.urlInfo;
    
    [self routeWithScheme:urlInfo.scheme server:urlInfo.server key:urlInfo.key parameter:urlInfo.parameter completion:completion];
}


- (void)routeWithScheme:(NSString *)scheme server:(NSString *)server key:(NSString *)key parameter:(NSDictionary *)parameterDict completion:(void(^)(NSError *error, TFRouteResponse *reponseData))completion
{
    NSLog(@"%s", __func__);
    
    TFRouteRequest *request = [[TFRouteRequest alloc] initWithScheme:scheme server:server key:key parameter:parameterDict];
    self.request = request;

    if (self.routeTable == nil) {
        [self returnError:-1 localizedDescription:@"路由表为空" byCompletionBlock:completion];
        return;
    }
    
    if (self.routeTable[server] == nil) {
        [self returnError:-1 localizedDescription:@"当前域名不支持路由" byCompletionBlock:completion];
        return;
    }
    
    if (scheme != nil && [scheme isEqualToString:@"action"]) {
        NSLog(@"暂不支持操作");
        
        [self returnError:404 localizedDescription:@"暂不支持route调用操作" byCompletionBlock:completion];

        return;
    }
    else {
        
        NSDictionary *viewControllerNames = self.routeTable[server][@"ViewController"];
    
        if (viewControllerNames && viewControllerNames[key]) {
            // 获取类名
            NSString *className = viewControllerNames[key];
            
            Class clazz = NSClassFromString(className);
            
            if ([clazz isSubclassOfClass:[UIViewController class]]) {
                
                // 初始化类
                UIViewController *controller = [[clazz alloc] init];
                
                // 获取类的属性列表
                unsigned int count;
                objc_property_t *properties = class_copyPropertyList(clazz, &count);
                
                NSMutableArray *classPropertyArray = [NSMutableArray array];
                for (int i = 0; i < count; i++) {
                    
                    objc_property_t property = properties[i];
                    
                    const char *cName = property_getName(property);
                    
                    NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
                    [classPropertyArray addObject:name];
                }
                free(properties);
                
                // 上面的方法只能取到当前类的属性列表，还应循环取出所有父类的属性列表
                Class superClass = class_getSuperclass(clazz);
                while (superClass) {
                    @autoreleasepool {
                        unsigned int count;
                        objc_property_t *properties = class_copyPropertyList(superClass, &count);
                        for (int i = 0; i < count; i++) {
                            
                            objc_property_t property = properties[i];
                            
                            const char *cName = property_getName(property);
                            
                            NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
                            [classPropertyArray addObject:name];
                        }
                        free(properties);
                        superClass = class_getSuperclass(superClass);
                    }
                }
                
                // 设置相应的属性
                [classPropertyArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if (parameterDict[obj]) {
                        [controller setValue:parameterDict[obj] forKey:obj];
                    }
                    
                }];
                
                [self routeToViewController:controller completion:completion];
            }
        }
        else {
            
            if (self.routeDefaultClassName != nil) {
                id defaultClass = [[NSClassFromString(self.routeDefaultClassName) alloc] init];
                
                if (defaultClass && [defaultClass isKindOfClass:[UIViewController class]]) {
                    if ([defaultClass respondsToSelector:@selector(setUrl:)] && self.request.url != nil) {
                        [defaultClass performSelector:@selector(setUrl:) withObject:self.request.url];
                    }
                    
                    [self routeToViewController:defaultClass completion:completion];
                }
                else {
                    [self routeToDefultViewController:completion];
                }
            }
            else {
                [self routeToDefultViewController:completion];
            }
        }
    }

    return;
}

- (void)routeToDefultViewController:(void(^)(NSError *error, id reponseData))completion
{
    NSLog(@"%s", __func__);
    RouteDefaultViewController *viewController = [[RouteDefaultViewController alloc] init];
    
    if (self.request.url != nil) {
        viewController.url = self.request.url;
    }
    
    [self routeToViewController:viewController completion:completion];
}

- (void)routeToViewController:(UIViewController *)viewController completion:(void(^)(NSError *error, id reponseData))completion
{
    NSLog(@"%s", __func__);
    UIView *preloadView = viewController.view;// 预先加载View
    NSLog(@"routeTo: %@ %@", NSStringFromClass([viewController class]), NSStringFromCGRect(preloadView.frame));
    
    // 获取当前顶层视图
    UIViewController *currentVC = [self getCurrentVC];
    
    if (currentVC.navigationController != nil) {
        [currentVC.navigationController pushViewController:viewController animated:YES];
        
        TFRouteResponse *response = [[TFRouteResponse alloc] initWithUrl:self.request.url statusCode:200];
        response.source = currentVC;
        response.target = viewController;
        
        self.response = response;
        completion(nil, response);
    }
    else {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        __block TFRouter *blockSelf = self;
        [currentVC presentViewController:navigationController animated:YES completion:^{
            
            TFRouteResponse *response = [[TFRouteResponse alloc] initWithUrl:blockSelf.request.url statusCode:200];
            response.source = currentVC;
            response.target = viewController;
            
            blockSelf.response = response;
            completion(nil, response);
        }];
    }

}



- (UIViewController *)getCurrentVC{
    NSLog(@"%s", __func__);
    
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
