//
//  WebViewController.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/16.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 20)];
//    label.text = @"test vc";
//    [self.view addSubview:label];
//    
//    UIWebView  *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 120, 320, 200)];
//    [self.view addSubview:webview];
    
    if (self.url != nil) {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
        [self.webview loadRequest:request];
    }
    
    
    self.urlLabel.text = self.url;
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


@end
