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
#import "UIViewController+CurrentVC.h"
#import "RouteDefaultViewController.h"


#define TFRouterErrorDomain @"TFRouterErrorDomain"

@interface TFRouter ()

/*
 @param routeTable 从RouteTable.plist读取的路由表
 
 方案一：
 {
    "scheme": {
                    "server": {
                                    "key": {
                                                "ClassName" : ClassName,
                                                "PropertyList" : [PropertyName, PropertyName, ...],
                                                "FunctionList" : {
                                                                    "FunctionName":[ParameterName, ParamterName, ...]
                                                                 }
                                            }
                              }
              }
 }
 
 方案二：
 {
    "scheme": {
                "server": {
                            "key": ClassName,
                            ...
                          }
              }
 }

 */

@property (nonatomic, strong) NSDictionary *routeTable;

@end

@implementation TFRouter

+(id)shared {
    
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

- (void)returnError:(NSInteger)errcode localizedDescription:(NSString *)localizedDescription byCompletionBlock:(void(^)(NSError *error, id reponseData))completion
{
    if (localizedDescription == nil) {
        localizedDescription = @"未知错误";
    }
    NSLog(@"TFRouterError: [%ld] %@", errcode, localizedDescription);
    if (completion) {
        NSError *error = [NSError errorWithDomain:TFRouterErrorDomain code:errcode userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
        completion(error, nil);
    }
}



- (void)routeWithUrl:(NSString*)url completion:(void(^)(NSError *error, id reponseData))completion
{
    if (url == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
        return;
    }
    
    TFRouteRequest *request = [[TFRouteRequest alloc] initWithUrl:url];
    
    if (request == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
    }

    [self routeWithRequest:request completion:completion];
    
}

- (void)routeWithRequest:(TFRouteRequest*)request completion:(void(^)(NSError *error, TFRouteResponse *reponse))completion
{
    if (request == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
        return;
    }
    
    self.request = request;
    
    TFURLInfo *urlInfo = request.urlInfo;
    
    [self routeWithScheme:urlInfo.scheme server:urlInfo.server key:urlInfo.key parameter:urlInfo.parameter completion:completion];
}


- (void)routeWithScheme:(NSString *)scheme server:(NSString *)server key:(NSString *)key parameter:(NSDictionary *)parameterDict completion:(void(^)(NSError *error, id reponseData))completion
{
    
    if (self.routeTable == nil) {
        [self returnError:-1 localizedDescription:nil byCompletionBlock:completion];
        return;
    }
    
    if (scheme != nil && [scheme isEqualToString:@"action"]) {
        NSLog(@"暂不支持操作");
        
        [self returnError:404 localizedDescription:@"暂不支持route调用操作" byCompletionBlock:completion];

        return;
    }
    else {
    
        if (self.routeTable[scheme][server][key]) {
            // 获取类名
            NSString *className = self.routeTable[scheme][server][key];
            
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
    RouteDefaultViewController *viewController = [[RouteDefaultViewController alloc] init];
    
    if (self.request.url != nil) {
        viewController.url = self.request.url;
    }
    
    [self routeToViewController:viewController completion:completion];
}

- (void)routeToViewController:(UIViewController *)viewController completion:(void(^)(NSError *error, id reponseData))completion
{
    UIView *preloadView = viewController.view;// 预先加载View
    NSLog(@"routeTo: %@ %@", NSStringFromClass([viewController class]), NSStringFromCGRect(preloadView.frame));
    
    // 获取当前顶层视图
    UIViewController *currentVC = [UIViewController getCurrentVC];
    
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



@end
