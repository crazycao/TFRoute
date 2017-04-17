//
//  TFRouteResponse.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "TFRouteResponse.h"

@implementation TFRouteResponse

- (instancetype)initWithUrl:(NSString *)url statusCode:(NSInteger)statusCode
{
    self = [super init];
    if (self) {
        _url = url;
        _statusCode = statusCode;
        _source = nil;
        _target = nil;
    }
    return self;
}

@end
