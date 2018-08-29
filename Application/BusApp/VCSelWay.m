//
//  VCSelWay.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCSelWay.h"
#import "VCCheckIn.h"
#import "VCSortList.h"

@interface VCSelWay ()

@end

@implementation VCSelWay

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Which way?";
    UIButton *goSchool = [UIButton buttonWithType:UIButtonTypeCustom];
    goSchool.clipsToBounds = YES;
    goSchool.layer.cornerRadius = LINEH / 4;
    goSchool.tag = 1;
    goSchool.frame = CGRectMake(SCREENW / 4, SCREENH / 2 - 2 * LINEH, SCREENW / 2, LINEH);
    goSchool.backgroundColor = BTN_COLOR;
    [goSchool setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [goSchool setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [goSchool setTitle:@"To school" forState:UIControlStateNormal];
    [goSchool addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *goHome = [UIButton buttonWithType:UIButtonTypeCustom];
    goHome.clipsToBounds = YES;
    goHome.layer.cornerRadius = LINEH / 4;
    goHome.tag = 2;
    goHome.frame = CGRectMake(SCREENW / 4, SCREENH / 2, SCREENW / 2, LINEH);
    goHome.backgroundColor = BTN_COLOR;
    [goHome setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [goHome setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [goHome setTitle:@"To home" forState:UIControlStateNormal];
    [goHome addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *sortList = [UIButton buttonWithType:UIButtonTypeCustom];
    sortList.clipsToBounds = YES;
    sortList.layer.cornerRadius = LINEH / 4;
    sortList.tag = 3;
    sortList.frame = CGRectMake(SCREENW / 4, SCREENH / 2 + 2 * LINEH, SCREENW / 2, LINEH);
    sortList.backgroundColor = BTN_COLOR;
    [sortList setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [sortList setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [sortList setTitle:@"list of children" forState:UIControlStateNormal];
    [sortList addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:goSchool];
    [self.view addSubview:goHome];
    [self.view addSubview:sortList];
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

-(void)btnClick:(UIButton *)sender
{
    if (1 == sender.tag || 2 == sender.tag) {
        VCCheckIn *vc = [[VCCheckIn alloc] init];
        vc.type = (int)sender.tag - 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (3 == sender.tag) {
        VCSortList *vc = [[VCSortList alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //UITextField *user = [self.view viewWithTag:1];
    //UITextField *password = [self.view viewWithTag:2];
    //VCMyBus *vc = [[VCMyBus alloc] init];
    //vc.type = (int)user.text.length;
    //[self.navigationController pushViewController:vc animated:YES];
}

@end
