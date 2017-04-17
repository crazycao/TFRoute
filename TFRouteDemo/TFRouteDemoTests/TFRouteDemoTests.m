//
//  TFRouteDemoTests.m
//  TFRouteDemoTests
//
//  Created by crazycao on 17/3/15.
//  Copyright © 2017年 crazycao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TFRouter.h"
#import "UIViewController+CurrentVC.h"
#import "WebViewController.h"

@interface TFRouteDemoTests : XCTestCase

@end

@implementation TFRouteDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    [[TFRouter shared] routeWithUrl:@"http://m.taofen8.com/wl.html?url=http://m.baidu.com" completion:^(NSError *error, id reponseData) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
        }
        
        XCTAssertEqualObjects([[UIViewController getCurrentVC] class],
                              [WebViewController class]);

    }];    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
