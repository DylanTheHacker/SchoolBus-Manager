//
//  VCSortList.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCSortList.h"

@interface VCSortList ()

@end

@implementation VCSortList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Children List";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = LINEH / 4;
    button.tag = 2;
    button.frame = CGRectMake(LINEH, SCREENH - 2 * LINEH, SCREENW - 2 * LINEH, LINEH);
    button.backgroundColor = BTN_COLOR;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UITableView *userList = [[UITableView alloc]initWithFrame:
                             CGRectMake(0, TOPH + LINEH, SCREENW, SCREENH - (TOPH + LINEH) - 3 * LINEH)];
    userList.tag = -1;
    userList.backgroundColor = UIColor.clearColor;
    [userList setEditing:YES animated:YES];
    [self.view addSubview:userList];
    
    self.userListContent = [[NSMutableArray alloc] init];
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/GetStudentsSort.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"DriverID":app.strUser,
                           @"BusID":app.strBus,
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    urlRequest.HTTPBody = data;
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *go = [urlSession
                                dataTaskWithRequest:urlRequest
                                completionHandler:^(NSData * _Nullable data,
                                                    NSURLResponse * _Nullable response,
                                                    NSError * _Nullable error) {
                                    NSString *msg = @"error";
                                    NSString *ret = @"";
                                    if (nil == error) {
                                        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:nil];
                                        ret = [dic objectForKey:@"ResultCode"];
                                        self.userListContent = [dic objectForKey:@"StudentsSortArray"];
                                        if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                        if ([ret isEqualToString:@"2401"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2402"]) msg = @"";
                                        //if ([ret isEqualToString:@"2403"]) msg = @"";
                                        if ([ret isEqualToString:@"2404"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"2405"]) msg = @"";
                                        if ([ret isEqualToString:@"2406"]) msg = @"list empty";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            UITableView *userList = [self.view viewWithTag:-1];
                                            userList.delegate = self;
                                            userList.dataSource = self;
                                            [userList reloadData];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                        if (0 == self.userListContent.count) {
                                            UIButton *button = [self.view viewWithTag:2];
                                            [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
                                            button.enabled = NO;
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
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

-(void)buttonClick:(UIButton *)sender
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/UploadStudentsSort.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"DriverID":app.strUser,
                           @"BusID":app.strBus,
                           @"StudentsSortArray":self.userListContent,
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    urlRequest.HTTPBody = data;
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *go = [urlSession
                                dataTaskWithRequest:urlRequest
                                completionHandler:^(NSData * _Nullable data,
                                                    NSURLResponse * _Nullable response,
                                                    NSError * _Nullable error) {
                                    NSString *msg = @"error";
                                    NSString *ret = @"";
                                    if (nil == error) {
                                        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:nil];
                                        ret = [dic objectForKey:@"ResultCode"];
                                        if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                        if ([ret isEqualToString:@"2501"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2502"]) msg = @"";
                                        //if ([ret isEqualToString:@"2503"]) msg = @"";
                                        if ([ret isEqualToString:@"2504"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"2505"]) msg = @"";
                                        if ([ret isEqualToString:@"2506"]) msg = @"list empty";
                                        //if ([ret isEqualToString:@"2507"]) msg = @"";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            [self.navigationController popViewControllerAnimated:YES];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:SimpleTableIdentifier];
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableString *busItem = self.userListContent[indexPath.row];
    NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@",[info objectForKey:@"StudentName"]];
    cell.detailTextLabel.text = [info objectForKey:@"FamilyAddress"];
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userListContent.count;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableDictionary *dic = self.userListContent[sourceIndexPath.row];
    [self.userListContent removeObjectAtIndex:sourceIndexPath.row];
    [self.userListContent insertObject:dic atIndex:destinationIndexPath.row];
}

@end
