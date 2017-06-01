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


- (instancetype)initWithURLInfo:(TFURLInfo *)urlInfo
{
    if (urlInfo == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _urlInfo = urlInfo;
        
        _url = [NSString stringWithFormat:@"http://%@/%@", urlInfo.server, urlInfo.key];
        
        if (urlInfo.parameter != nil) {
            NSString *parameterString = [self createStringFromParameter:urlInfo.parameter];
            if (parameterString != nil) {
                _url = [NSString stringWithFormat:@"%@?%@", _url, parameterString];
            }
        }
    }
    return self;
}

- (instancetype)initWithScheme:(NSString *)scheme server:(NSString *)server key:(NSString *)key parameter:(NSDictionary *)parameter
{
    self = [super init];
    if (self) {
        TFURLInfo *urlInfo = [[TFURLInfo alloc] init];
        urlInfo.scheme = scheme;
        urlInfo.server = server;
        urlInfo.key = key;
        urlInfo.parameter = parameter;
        
        _urlInfo = urlInfo;
        _url = [NSString stringWithFormat:@"http://%@/%@", urlInfo.server, urlInfo.key];
        
        if (urlInfo.parameter != nil) {
            NSString *parameterString = [self createStringFromParameter:urlInfo.parameter];
            if (parameterString != nil) {
                _url = [NSString stringWithFormat:@"%@?%@", _url, parameterString];
            }
        }
    }
    return self;
}

- (NSString *)createStringFromParameter:(NSDictionary *)parameter
{
    if (parameter == nil) {
        return nil;
    }
    
    NSString *result = nil;
    NSMutableString *muString = [NSMutableString string];
    for (NSString *key in parameter.allKeys) {
        NSString *value = parameter[key];
        [muString appendFormat:@"&%@=%@", key, value];
    }
    if (muString.length > 1) {
        result = [muString substringFromIndex:1];
    }
    return result;
}

@end
