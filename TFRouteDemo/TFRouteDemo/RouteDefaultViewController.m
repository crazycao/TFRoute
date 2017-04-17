//
//  RouteDefaultViewController.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/30.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "RouteDefaultViewController.h"
//#import <WebKit/WebKit.h>

@interface RouteDefaultViewController () <UIWebViewDelegate>

//@property (strong, nonatomic) WKWebView *webview;
@property (strong, nonatomic) UIWebView *webview;

@end

@implementation RouteDefaultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Hello World!";
    
//    self.webview = [[WKWebView alloc] init];
    self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webview];
    
    self.webview.delegate = self;
    
    if (self.url != nil) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        [self.webview loadRequest:request];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
