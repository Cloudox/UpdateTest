//
//  ViewController.m
//  UpdateTest
//
//  Created by csdc-iMac on 15/8/17.
//  Copyright (c) 2015年 csdc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 检查更新
    [self onCheckVersion];
}

- (void)onCheckVersion {
    NSString *currentVersion = @"0.9"; // 现在的版本
    NSString *appID = @"356087517";// 此app的ID
    // 请求url
    NSString *versionUrl = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", appID];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:versionUrl]];
    
    // 收到的回复
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    
    // 转换成键值对形式
    NSError *error;
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"error: %@", [error description]);
        return;
    }
    NSLog(@"%@", appInfoDic);// 可输出查看回复的信息
    // 查看具体内容中内容数是否为空
    NSArray *resultsArray = [appInfoDic objectForKey:@"results"];
    if (![resultsArray count]) {
        NSLog(@"error: resultsArray == nil");
        return;
    }
    // 获取具体需要的信息
    NSDictionary *infoDic = [resultsArray objectAtIndex:0];
    self.latestVersion = [infoDic objectForKey:@"version"];// 版本号
    self.trackViewUrl = [infoDic objectForKey:@"trackViewUrl"];// 更新的url地址
    
    // 弹出提示框
    NSString *messageStr = [NSString stringWithFormat:@"发现新版本：%@，是否前往更新？", self.latestVersion];
    if (![currentVersion isEqualToString:self.latestVersion]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:messageStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
        alert.tag = 10000;
        [alert show];
    }
}

// 提示框的响应
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            // 前往app store更新
            NSURL *url = [NSURL URLWithString:self.trackViewUrl];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
