//
//  TFURLInfo.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "TFURLInfo.h"

@implementation TFURLInfo

- (instancetype)initWithUrl:(NSString *)urlString
{
    if (urlString == nil || [urlString isEqualToString:@""]) {
        return nil;
    }
    
    NSURL *urlObject = [NSURL URLWithString:urlString];
    if (urlObject == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        
        [self parseURL:urlObject];
    }
    
    return self;
}

- (void)parseURL:(NSURL *)url
{
    if (url == nil) {
        return;
    }
    
    // 找到参数
    NSString *query = [url query];
    
    NSArray *arr = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < arr.count; i++) {
        
        NSArray *str = [arr[i] componentsSeparatedByString:@"="];
        
        if (str.count == 2) {
            [parameterDict setObject:str[1] forKey:str[0]];
        }
        else if (str.count > 2){
            
            NSMutableString *appending = [[NSMutableString alloc] initWithCapacity:0];
            for (NSUInteger j = str.count - 1; j == 1; j--) {
                [appending appendString:str[j]];
            }
            
            [parameterDict setObject:appending forKey:str[0]];
        }
        else {
            NSLog(@"没有等号的参数跳过");
        }
    }
    
    _parameter = [parameterDict copy];
    
    // 找到key
    NSString *path = [url path];
    NSRange range = [path rangeOfString:@"."];
    
    if (range.length == 0) {// 没找到“.”
        range.length = path.length - 1;// “/”之后的都是
    }
    else {// 找到“.”
        range.length = range.location - 1;// “.”之前，“/”之后
    }
    range.location = 1;// 从“/”之后开始
    _key = [path substringWithRange:range];
    
    _server = [url host];
    
    _scheme = [url scheme];
    if (_scheme != nil && [_scheme isEqualToString:@"http"]) {
        _scheme = @"push";
    }
}

@end
