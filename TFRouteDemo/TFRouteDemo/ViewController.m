//
//  ViewController.m
//  TFRouteDemo
//
//  Created by crazycao on 17/3/15.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import "ViewController.h"
#import "TFRouter.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 60, 40)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btnAction:(UIButton *)btn
{
//    WebViewController *web = [[WebViewController alloc] init];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:web];
//    
//    [self presentViewController:nav animated:YES completion:nil];
    
    
    [[TFRouter shared] routeWithUrl:@"http://m.taofen8.com/" completion:^(NSError *error, id reponseData) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
        
    }];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
