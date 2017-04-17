//
//  TFRouteRequest.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "TFRouteRequest.h"

@implementation TFRouteRequest

- (instancetype) initWithUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        _url = url;
        _urlInfo = [[TFURLInfo alloc] initWithUrl:url];
    }
    return self;
}

@end
