//
//  TFURLInfo.h
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFURLInfo : NSObject

@property (nonatomic, copy) NSString *scheme;
@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSDictionary *parameter;

- (instancetype)initWithUrl:(NSString *)urlString;

@end
