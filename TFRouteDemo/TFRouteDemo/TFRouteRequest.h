//
//  TFRouteRequest.h
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFURLInfo.h"

@interface TFRouteRequest : NSObject

@property (readonly, copy) NSString *url; // 路由的初始url
//@property (readonly, copy) NSString *ruleType; // url使用的规则类型
//@property (readonly, copy) NSString *replacement; // 将url通过nginx转换的结果
//@property (copy, nonatomic) NSString *routeMethod; // 路由请求的方法，GET/POST等
//@property (strong, nonatomic) NSData *postData; // 主要用于传递非基本类型的数据（基本类型一般转成了replacement）
//@property (weak, nonatomic) UIViewController *source; // 路由请求的来源界面，Android为sourceActivity

@property (strong, nonatomic) TFURLInfo *urlInfo;

- (instancetype)initWithUrl:(NSString *)url; // 通过url初始化路由请求，url会被nginx替换成ruleType和replacement
//- (instancetype) initWithRule:(NSString *)ruleType andReplacement:(NSString *)replacement; // 通过ruleType和replacement初始化路由请求，通过这种方法初始化时不会调用nginx方法
//- (void)setSourceVC:(UIViewController *)sourceVC; //设置来源界面，若未设置或设置为nil，NativeRoute会尽力获取到当前最上层的VC以保证成功路由
- (instancetype)initWithURLInfo:(TFURLInfo *)urlInfo;
- (instancetype)initWithScheme:(NSString *)scheme server:(NSString *)server key:(NSString *)key parameter:(NSDictionary *)parameter;

@end
