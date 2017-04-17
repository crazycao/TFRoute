//
//  TFURLInfo.h
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFURLInfo : NSObject

@property (readonly, copy) NSString *scheme;
@property (readonly, copy) NSString *server;
@property (readonly, copy) NSString *key;
@property (readonly, copy) NSDictionary *parameter;

- (instancetype)initWithUrl:(NSString *)urlString;

@end
