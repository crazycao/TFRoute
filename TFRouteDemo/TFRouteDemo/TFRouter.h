//
//  TFRouter.h
//  TFRouteDemo
//
//  Created by crazycao on 17/3/15.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFRouteRequest.h"
#import "TFRouteResponse.h"
#import "UIViewController+CurrentVC.h"

@interface TFRouter : NSObject


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

/**
 初始化
 */

+ (instancetype)shared;


//- (void)registerScheme


/**
 内部调用
 
 @param scheme 方案，打开界面或调用方法
 @param server 服务器，对应URL中的host
 @param key 识别标记，用于找到对应的界面
 @param parameter 对应的参数
 @param completion 支持回调
 
 */
- (void)routeWithScheme:(NSString *)scheme server:(NSString *)server key:(NSString *)key parameter:(NSDictionary *)parameter completion:(void(^)(NSError *error, TFRouteResponse *reponseData))completion;

/**
 外部调用
 
 @param url 路由URL
 
 参考标准URL格式
 <scheme>://<host>/<path>?<query>#<anchor>
 
 <scheme>	——	方案，用于从外部或内部wap页打开客户端页面，或者H5主动调用客户端方法。
 <host>		——	域名，1、内嵌SDK使用不同的域名；2、可过滤掉异常的路由请求。
 <path>		——	路径，要打开的页面或要调用的功能的key，若该key能在路由表中查到，则可以打开相应的页面或功能。
 <query>	——	查询，打开页面或功能所需的参数。
 <anchor>	——	锚点，客户端暂时用不到。

 @param completion 支持回调
 
 */


- (void)routeWithUrl:(NSString*)url completion:(void(^)(NSError *error, TFRouteResponse *reponseData))completion;


- (void)routeWithRequest:(TFRouteRequest*)request completion:(void(^)(NSError *error, TFRouteResponse *reponse))completion;


@property (nonatomic, strong) TFRouteRequest *request;
@property (nonatomic, strong) TFRouteResponse *response;

@property (nonatomic, strong) NSString *routeDefaultClassName;


- (void)pushViewController:(UIViewController *)viewController byViewController:(UIViewController *)currentViewController completion:(void (^ __nullable)(void))completion;
- (void)presentViewController:(UIViewController *)viewController byViewController:(UIViewController *)currentViewController completion:(void (^ __nullable)(void))completion;

@end
