//
//  VCMyBus.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCMyBus.h"
#import "VCJoinBus.h"
#import "VCLookBus.h"
#import "VCSelWay.h"

@interface VCMyBus ()

@end

@implementation VCMyBus

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"My Buses";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = LINEH / 4;
    button.frame = CGRectMake(SCREENW / 4, SCREENH - 2 * LINEH, SCREENW / 2, LINEH);
    button.backgroundColor = BTN_COLOR;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [button setTitle:self.type?@"Add Bus":@"Join Bus" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"Login"
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }

    UIScrollView *busList = [[UIScrollView alloc]initWithFrame:
                             CGRectMake(0, TOPH + LINEH, SCREENW, SCREENH - (TOPH + LINEH) - 3 * LINEH)];
    busList.tag = -1;
    [self.view addSubview:busList];
    busList.hidden = YES;
    UITableView *busList2 = [[UITableView alloc]initWithFrame:busList.frame];
    busList2.tag = -2;
    busList2.backgroundColor = UIColor.clearColor;
    busList2.allowsSelectionDuringEditing = YES;
    [self.view addSubview:busList2];
    
    self.busListContent = [[NSMutableArray alloc] init];
    self.busListContentSel = [[NSMutableString alloc] init];
    [self updateMyBus];
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
    if (self.type) { // driver
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.placeholder = @"bus name";
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    UITextField *busname = alert.textFields[0];
                                                    if (busname.text.length) {
                                                        [self addMyBus:busname.text];
                                                    } else {
                                                        APPCODE;
                                                        UIAlertController *alert = [app getMsgBox:@"Name cannot be empty" :nil];
                                                        [self presentViewController:alert animated:YES completion:nil];
                                                    }
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        VCJoinBus *vc = [[VCJoinBus alloc] init];
        vc.pParentBus = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)busClick:(UIButton *)sender
{
    UIButton *bus = (UIButton *)sender;
    if (3 == bus.tag % 100) { // del
        UIScrollView *busList = [self.view viewWithTag:-1];
        UIButton *busIDBtn = [busList viewWithTag:sender.tag - 1];
        NSRange range = [busIDBtn.currentTitle rangeOfString:@" "];
        if (self.type) { // driver
        } else {
            range.location = busIDBtn.currentTitle.length;
        }
        NSString *busID = [[NSString alloc] initWithFormat:@"%@",
                           [busIDBtn.currentTitle substringToIndex:range.location]];
        NSString *msg = [NSString stringWithFormat:@"delete %@", busID];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                    [self delMyBus:busID];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    APPCODE;
    if (self.type) { // driver
        NSRange range = [bus.currentTitle rangeOfString:@" "];
        app.strBus = [[NSString alloc] initWithFormat:@"%@", [bus.currentTitle substringToIndex:range.location]];
        //app.vcMyBus = self;
        VCSelWay *vc = [[VCSelWay alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (self.busListContentSel.length
            && [self.busListContentSel isEqualToString:bus.currentTitle]) {
            app.strBus = [[NSString alloc] initWithFormat:@"%@", self.busListContentSel];
            VCLookBus *vc = [[VCLookBus alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            if (self.busListContentSel.length) {
                NSDictionary *tmp = @{@"SelectedVehicleBusID":@""};
                self.busListContentSel = [tmp objectForKey:@"SelectedVehicleBusID"];
            }
            NSDictionary *tmp = @{@"SelectedVehicleBusID":bus.currentTitle};
            self.busListContentSel = [tmp objectForKey:@"SelectedVehicleBusID"];
            [self selMyBus];
        }
    }
}

-(void)updateMyBus
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/%@",
                     [app setServer:SERVER], self.type?@"GetDriverAddedVehicles.ashx":@"GetParentAddedVehicles.ashx"];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           (self.type?@"DriverID":@"ParentID"):app.strUser,
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
                                    if (self.busListContent.count) {
                                        [self.busListContent removeAllObjects];
                                    }
                                    if (self.busListContentSel.length) {
                                        NSDictionary *tmp = @{@"SelectedVehicleBusID":@""};
                                        self.busListContentSel = [tmp objectForKey:@"SelectedVehicleBusID"];
                                    }
                                    if (nil == error) {
                                        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:nil];
                                        ret = [dic objectForKey:@"ResultCode"];
                                        if (self.type) {
                                            self.busListContent = [dic objectForKey:@"VehiclesArray"];
                                            if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                            if ([ret isEqualToString:@"2201"]) msg = @"json error";
                                            //if ([ret isEqualToString:@"2202"]) msg = @"";
                                            //if ([ret isEqualToString:@"2203"]) msg = @"";
                                            if ([ret isEqualToString:@"2204"]) msg = @"token error";
                                            if ([ret isEqualToString:@"2205"]) msg = @"Empty List";
                                        } else {
                                            self.busListContentSel = [dic objectForKey:@"SelectedVehicleBusID"];
                                            self.busListContent = [dic objectForKey:@"AddedVehiclesArray"];
                                            if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                            if ([ret isEqualToString:@"2701"]) msg = @"json error";
                                            //if ([ret isEqualToString:@"2702"]) msg = @"";
                                            //if ([ret isEqualToString:@"2703"]) msg = @"";
                                            if ([ret isEqualToString:@"2704"]) msg = @"token error";
                                            if ([ret isEqualToString:@"2705"]) msg = @"Empty List";
                                        }
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            UIScrollView *busList = [self.view viewWithTag:-1];
                                            [busList.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                            int tagBus = 0;
                                            for (NSMutableString *busItem in self.busListContent) {
                                                NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                            options:NSJSONReadingMutableContainers
                                                                                                              error:nil];
                                                NSString *strBusID = [info objectForKey:@"BusID"];
                                                NSString *strBusPWD = [info objectForKey:@"BusPWD"];
                                                if (self.type) {
                                                    if ([strBusID isEqualToString:@""]
                                                        || [strBusPWD isEqualToString:@""]) {
                                                        continue;
                                                    }
                                                } else {
                                                    if ([strBusID isEqualToString:@""]) {
                                                        continue;
                                                    }
                                                }
                                                UIButton *bus = [UIButton buttonWithType:UIButtonTypeCustom];
                                                bus.tag = 100 * tagBus + 2;
                                                bus.frame = CGRectMake(LINEH, LINEH / 2 + tagBus * 3 * LINEH / 2, SCREENW - 3 * LINEH, LINEH);
                                                bus.backgroundColor = UIColor.greenColor;
                                                if (self.busListContentSel.length
                                                    && [self.busListContentSel isEqualToString:strBusID]) {
                                                    [bus setTitleColor:UIColor.redColor forState:UIControlStateNormal];
                                                } else {
                                                    [bus setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                                                }
                                                [bus setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
                                                NSString *buttonLabel = nil;
                                                if (self.type) {
                                                    buttonLabel = [[NSString alloc] initWithFormat:@"%@ %@",
                                                                   strBusID, strBusPWD];
                                                } else {
                                                    buttonLabel = [[NSString alloc] initWithFormat:@"%@",
                                                                   strBusID];
                                                }
                                                [bus setTitle:buttonLabel forState:UIControlStateNormal];
                                                [bus addTarget:self action:@selector(busClick:) forControlEvents:UIControlEventTouchUpInside];
                                                UIButton *userRight = [UIButton buttonWithType:UIButtonTypeCustom];
                                                userRight.tag = 100 * tagBus + 3;
                                                userRight.frame = CGRectMake(SCREENW - 2 * LINEH, LINEH / 2 + tagBus * 3 * LINEH / 2, LINEH, LINEH);
                                                userRight.backgroundColor = UIColor.grayColor;
                                                [userRight setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                                                [userRight setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
                                                [userRight setTitle:@"㐅" forState:UIControlStateNormal];
                                                [userRight addTarget:self action:@selector(busClick:) forControlEvents:UIControlEventTouchUpInside];
                                                [busList addSubview:bus];
                                                [busList addSubview:userRight];
                                                tagBus++;
                                            }
                                            busList.contentSize = CGSizeMake(busList.frame.size.width, LINEH / 2 + tagBus * 3 * LINEH / 2);
                                            if (0 == tagBus) {
                                                UIAlertController *alert = [app getMsgBox:@"Empty List!" :nil];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                            UITableView *busList2 = [self.view viewWithTag:-2];
                                            busList2.delegate = self;
                                            busList2.dataSource = self;
                                            [busList2 reloadData];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(void)selMyBus
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/UploadParentSelectedVehicle.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"ParentID":app.strUser,
                           @"BusID":self.busListContentSel,
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
                                        if ([ret isEqualToString:@"2901"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2902"]) msg = @"";
                                        //if ([ret isEqualToString:@"2903"]) msg = @"";
                                        if ([ret isEqualToString:@"2904"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"2905"]) msg = @"";
                                        //if ([ret isEqualToString:@"2906"]) msg = @"";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            UIScrollView *busList = [self.view viewWithTag:-1];
                                            for (UIView *obj in busList.subviews) {
                                                UIButton *bus = (UIButton *)obj;
                                                if ([self.busListContentSel isEqualToString:bus.currentTitle]) {
                                                    [bus setTitleColor:UIColor.redColor forState:UIControlStateNormal];
                                                } else {
                                                    [bus setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                                                }
                                            }
                                            UITableView *busList2 = [self.view viewWithTag:-2];
                                            busList2.delegate = self;
                                            busList2.dataSource = self;
                                            [busList2 reloadData];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(void)delMyBus:(NSString *)busID
{
    APPCODE;
    NSString *strD = [NSString stringWithFormat:@"%@/DeleteSelectedVehicleThroughDriver.ashx", [app setServer:SERVER]];
    NSString *strP = [NSString stringWithFormat:@"%@/DeleteSelectedVehicleThroughParent.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:self.type?strD:strP];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           (self.type?@"DriverID":@"ParentID"):app.strUser,
                           @"BusID":busID,
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
                                        if (self.type) {
                                            if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                            if ([ret isEqualToString:@"3301"]) msg = @"json error";
                                            //if ([ret isEqualToString:@"3302"]) msg = @"";
                                            //if ([ret isEqualToString:@"3303"]) msg = @"";
                                            if ([ret isEqualToString:@"3304"]) msg = @"token error";
                                            //if ([ret isEqualToString:@"3305"]) msg = @"";
                                            //if ([ret isEqualToString:@"3306"]) msg = @"";
                                        } else {
                                            if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                            if ([ret isEqualToString:@"3401"]) msg = @"json error";
                                            //if ([ret isEqualToString:@"3402"]) msg = @"";
                                            //if ([ret isEqualToString:@"3403"]) msg = @"";
                                            if ([ret isEqualToString:@"3404"]) msg = @"token error";
                                            //if ([ret isEqualToString:@"3405"]) msg = @"";
                                            //if ([ret isEqualToString:@"3406"]) msg = @"";
                                        }
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            [self updateMyBus];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(void)addMyBus:(NSString *)busName
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/UploadDriverAddVehicle.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"DriverID":app.strUser,
                           @"BusName":busName,
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
                                        if ([ret isEqualToString:@"2301"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2302"]) msg = @"";
                                        //if ([ret isEqualToString:@"2303"]) msg = @"";
                                        if ([ret isEqualToString:@"2304"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"2305"]) msg = @"";
                                        //if ([ret isEqualToString:@"2306"]) msg = @"";
                                        if ([ret isEqualToString:@"2307"]) msg = @"bus existed";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            [self updateMyBus];
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
    NSMutableString *busItem = self.busListContent[indexPath.row];
    NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *strBusID = [info objectForKey:@"BusID"];
    NSString *strBusName = [info objectForKey:@"BusName"];
    cell.textLabel.text = strBusName.length?strBusName:strBusID;
    cell.textLabel.textColor = UIColor.blackColor;
    cell.detailTextLabel.textColor = cell.textLabel.textColor;
    if (self.type) {
        cell.detailTextLabel.text = [info objectForKey:@"BusPWD"];
    } else {
        if (self.busListContentSel.length
            && [self.busListContentSel isEqualToString:strBusID]) {
            cell.detailTextLabel.text = @"●";
        } else {
            cell.detailTextLabel.text = @"";
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    for (NSMutableString *busItem in self.busListContent) {
        NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        NSString *strBusID = [info objectForKey:@"BusID"];
        NSString *strBusPWD = [info objectForKey:@"BusPWD"];
        if (self.type) {
            if ([strBusID isEqualToString:@""]
                || [strBusPWD isEqualToString:@""]) {
                [self.busListContent removeObject:busItem];
            }
        } else {
            if ([strBusID isEqualToString:@""]) {
                [self.busListContent removeObject:busItem];
            }
        }
    }
    return self.busListContent.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableString *busItem = self.busListContent[indexPath.row];
        NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        NSString *busID = [info objectForKey:@"BusID"];
        [self delMyBus:busID];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableString *busItem = self.busListContent[indexPath.row];
    NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *busID = [info objectForKey:@"BusID"];
    APPCODE;
    if (self.type) { // driver
        app.strBus = busID;
        //app.vcMyBus = self;
        VCSelWay *vc = [[VCSelWay alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (self.busListContentSel.length
            && [self.busListContentSel isEqualToString:busID]) {
            app.strBus = [[NSString alloc] initWithFormat:@"%@", self.busListContentSel];
            VCLookBus *vc = [[VCLookBus alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            if (self.busListContentSel.length) {
                NSDictionary *tmp = @{@"SelectedVehicleBusID":@""};
                self.busListContentSel = [tmp objectForKey:@"SelectedVehicleBusID"];
            }
            NSDictionary *tmp = @{@"SelectedVehicleBusID":busID};
            self.busListContentSel = [tmp objectForKey:@"SelectedVehicleBusID"];
            [self selMyBus];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *del
    = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                         title:@"㐅" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                             NSMutableString *busItem = self.busListContent[indexPath.row];
                                             NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:nil];
                                             NSString *busID = [info objectForKey:@"BusID"];
                                             [self delMyBus:busID];
                                         }];
    return @[del];
}

@end
