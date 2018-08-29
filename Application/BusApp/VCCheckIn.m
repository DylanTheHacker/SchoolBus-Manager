//
//  VCCheckIn.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCCheckIn.h"
#import "POilBtn.h"

@interface VCCheckIn ()

@end

@implementation VCCheckIn

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView  *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.presentFlg = 0;
    self.navigationController.delegate = self;
    self.title = self.type?@"To Home":@"To School";
    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    msgBtn.clipsToBounds = YES;
    msgBtn.layer.cornerRadius = LINEH / 4;
    msgBtn.tag = 2;
    msgBtn.frame = CGRectMake(7 * LINEH / 2, SCREENH - 2 * LINEH, SCREENW - 7 * LINEH, LINEH);
    msgBtn.backgroundColor = BTN_COLOR;
    [msgBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [msgBtn setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [msgBtn setTitle:@"Broadcast" forState:UIControlStateNormal];
    [msgBtn addTarget:self action:@selector(messageClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:msgBtn];
    
    UIScrollView *userList = [[UIScrollView alloc]initWithFrame:
                              CGRectMake(0, TOPH + LINEH, SCREENW, SCREENH - (TOPH + LINEH) - 3 * LINEH)];
    userList.tag = -1;
    [self.view addSubview:userList];
    
    self.userListContent = [[NSMutableArray alloc] init];
    self.xyGps = kCLLocationCoordinate2DInvalid;
    self.alertList = [[NSMutableArray alloc] init];
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
                                            UIScrollView *userList = [self.view viewWithTag:-1];
                                            [userList.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                                            int tagUser = 0;
                                            for (NSMutableString *busItem in self.userListContent) {
                                                NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                            options:NSJSONReadingMutableContainers
                                                                                                              error:nil];
                                                NSString *strUserID = [info objectForKey:@"StudentID"];
                                                NSString *strUserName = [info objectForKey:@"StudentName"];
                                                if ([strUserID isEqualToString:@""]
                                                    || [strUserName isEqualToString:@""]) {
                                                    continue;
                                                }
                                                UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(LINEH / 2, LINEH / 4 + 1 + tagUser * 5 * LINEH / 2, SCREENW - LINEH, 5 * LINEH / 2 - 2)];
                                                bg.backgroundColor = BG_COLOR;
                                                bg.clipsToBounds = YES;
                                                bg.layer.cornerRadius = LINEH / 4;
                                                UIButton *user = [UIButton buttonWithType:UIButtonTypeCustom];
                                                user.tag = 100 * tagUser + 1;
                                                user.frame = CGRectMake(7 * LINEH / 2, LINEH + tagUser * 5 * LINEH / 2, SCREENW - 7 * LINEH, LINEH);
                                                user.clipsToBounds = YES;
                                                user.layer.cornerRadius = LINEH / 4;
                                                user.backgroundColor = BTN_COLOR;
                                                [user setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                                                [user setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
                                                NSString *buttonLabel = [[NSString alloc] initWithFormat:@"%@", strUserName];
                                                [user setTitle:buttonLabel forState:UIControlStateNormal];
                                                [user addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                                                POilBtn *userLeft = [POilBtn buttonWithType:UIButtonTypeCustom];
                                                userLeft.backgroundColor = userLeft.backColorNormal = UIColor.whiteColor;
                                                userLeft.backColorHighlighted = UIColor.grayColor;
                                                userLeft.tag = 100 * tagUser + 2;
                                                userLeft.frame = CGRectMake(LINEH, LINEH / 2 + tagUser * 5 * LINEH / 2, 2 * LINEH, 2 * LINEH);
                                                userLeft.clipsToBounds = YES;
                                                userLeft.layer.cornerRadius = LINEH;
                                                userLeft.titleLabel.font = [UIFont systemFontOfSize: 3 * LINEH / 2];
                                                [userLeft setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
                                                [userLeft setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
                                                [userLeft addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                                                UIButton *userRight = [UIButton buttonWithType:UIButtonTypeCustom];
                                                userRight.clipsToBounds = YES;
                                                userRight.layer.cornerRadius = LINEH;
                                                userRight.tag = 100 * tagUser + 3;
                                                userRight.frame = CGRectMake(SCREENW - 3 * LINEH, LINEH / 2 + tagUser * 5 * LINEH / 2, 2 * LINEH, 2 * LINEH);
                                                [userRight setBackgroundImage:[UIImage imageNamed:@"warn.jpg"]
                                                                     forState:UIControlStateNormal];
                                                [userRight addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
                                                [userList addSubview:bg];
                                                [userList addSubview:user];
                                                [userList addSubview:userLeft];
                                                [userList addSubview:userRight];
                                                tagUser++;
                                            }
                                            userList.contentSize = CGSizeMake(userList.frame.size.width, LINEH / 2 + tagUser * 5 * LINEH / 2);
                                            [self chkUserStatus];
                                        } else {
                                            self.presentFlg = 1;
                                            UIAlertController *alert = [app getMsgBox:msg
                                                                                     :^(UIAlertAction *action) {
                                                                                         [self alertListCheck];
                                                                                     }];
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

    NSString *strWs = [NSString stringWithFormat:@"%@%@", [app setServer:SERVER_WS], app.strUser];
    NSURL *urlWs = [NSURL URLWithString:strWs];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:urlWs]];
    self.webSocket.delegate = self;
    [self.webSocket open];
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
    int tagUser = (int)sender.tag;
    int user = tagUser / 100;
    int btn = tagUser % 100;
    NSMutableString *userItem = self.userListContent[user];
    NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[userItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *strUserID = [info objectForKey:@"StudentID"];
    //NSString *strUserName = [info objectForKey:@"StudentName"];
    if (1 == btn) {
        [self messageSendToUser:strUserID];
    }
    if (2 == btn) {
        UIScrollView *userList = [self.view viewWithTag:-1];
        UIButton *userLeft = [userList viewWithTag:tagUser];
        if ([userLeft.currentTitle isEqualToString:@"○"]) {
            [userLeft setTitle:@"●" forState:UIControlStateNormal];
            [self messageSend:[self aboard2Dic:YES] :strUserID];
        } else if ([userLeft.currentTitle isEqualToString:@"●"]) {
            [userLeft setTitle:@"○" forState:UIControlStateNormal];
            [self messageSend:[self aboard2Dic:NO] :strUserID];
        }
    }
    if (3 == btn) {
        [self messageSend:[self str2Dic:self.type?@"Please let your child come quickly!":@"Please let your child come quickly!"] :strUserID];
    }
}

-(void)chkUserStatus
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSDate *datenow = [NSDate date];
    NSString *dateString = [formatter stringFromDate:datenow];
    int tagUser = 0;
    for (NSMutableString *busItem in self.userListContent) {
        NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        NSString *strUserID = [info objectForKey:@"StudentID"];
        if ([strUserID isEqualToString:@""]) {
            continue;
        }
        [self chkUserStatusProc:strUserID :dateString :tagUser];
        tagUser++;
    }
}

-(void)chkUserStatusProc:(NSString *)strUser :(NSString *)strDate :(int)tag
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/GetAbsentState.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"StudentID":strUser,
                           @"CurrentDate":strDate,
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
                                    NSString *status = @"";
                                    if (nil == error) {
                                        NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                     error:nil];
                                        ret = [dic objectForKey:@"ResultCode"];
                                        status = [dic objectForKey:@"AbsentStatus"];
                                        if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                        if ([ret isEqualToString:@"3101"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"3102"]) msg = @"";
                                        //if ([ret isEqualToString:@"3103"]) msg = @"";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //[app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            UIScrollView *userList = [self.view viewWithTag:-1];
                                            UIButton *userLeft = [userList viewWithTag:100 * tag + 2];
                                            if ([status isEqualToString:@"true"]) {
                                                [userLeft setTitle:@"–" forState:UIControlStateNormal];
                                            } else {
                                                [userLeft setTitle:@"○" forState:UIControlStateNormal];
                                            }
                                        } else {
                                            //self.presentFlg = 1;
                                            //UIAlertController *alert = [app getMsgBox:msg :nil];
                                            //[self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    //[app openActivity];
}

-(void)messageClick:(UIButton *)sender
{
    [self messageSendToUser:@""];
}

-(void)messageSendToUser:(NSString *)toId
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.placeholder = @"messge";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self alertListCheck];
                                                         }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *textField = (UITextField *)alert.textFields.firstObject;
                                                         if (textField.text.length) {
                                                             [self messageSend:[self str2Dic:textField.text] :toId];
                                                         }
                                                         [self alertListCheck];
                                                     }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    if (self.webSocket) {
        self.presentFlg = 1;
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(NSMutableDictionary *)str2Dic:(NSString *)str
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"string" forKey:@"type"];
    [dic setValue:str forKey:@"body"];
    return dic;
}

-(NSMutableDictionary *)xy2Dic:(CLLocationCoordinate2D)xy
{
    NSString *str = [NSString stringWithFormat:@"%lf %lf", xy.latitude, xy.longitude];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"location" forKey:@"type"];
    [dic setValue:str forKey:@"body"];
    return dic;
}

-(NSMutableDictionary *)xy002Dic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"locationStop" forKey:@"type"];
    [dic setValue:@"" forKey:@"body"];
    return dic;
}

-(NSMutableDictionary *)aboard2Dic:(BOOL)ret
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:ret?@"aboardYes":@"aboardYet" forKey:@"type"];
    if (self.type) { // back home
        [dic setValue:ret?@"Your child's abroad":@"I have dropped off your child" forKey:@"body"];
    } else { // goto scholl
        [dic setValue:ret?@"Your child's abroad":@"Your child is now at school" forKey:@"body"];
    }
    return dic;
}

-(void)messageSend:(NSMutableDictionary *)msg :(NSString *)toId
{
    APPCODE;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *dateString = [formatter stringFromDate:datenow];
    [msg setValue:dateString forKey:@"time"];
    [msg setValue:app.strName forKey:@"from"];
    [msg setValue:app.strUser forKey:@"fromId"];
    NSData *dataMsg = [NSJSONSerialization dataWithJSONObject:msg options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMsg = [[NSString alloc]initWithData:dataMsg encoding:NSUTF8StringEncoding];
    NSDictionary *json = @{
                           @"fromId":app.strName,
                           @"type":toId.length?@"2":@"1",
                           @"toId":toId.length?toId:app.strBus,
                           @"msgContent":strMsg,
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    if (self.webSocket) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (SR_OPEN == self.webSocket.readyState) {
                [self.webSocket send:data];
            } else {
                NSLog(@"Websocket readyState error");
            }
        });
    } else {
        NSLog(@"Websocket nil");
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    if (57 == error.code) {
        NSLog(@"Websocket Reopen");
        APPCODE;
        self.webSocket.delegate = nil;
        NSString *strWs = [NSString stringWithFormat:@"%@%@", [app setServer:SERVER_WS], app.strUser];
        NSURL *urlWs = [NSURL URLWithString:strWs];
        self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:urlWs]];
        self.webSocket.delegate = self;
        [self.webSocket open];
    } else {
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
        UIButton *msgBtn = [self.view viewWithTag:2];
        [msgBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        msgBtn.backgroundColor = UIColor.yellowColor;
        msgBtn.enabled = NO;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
    UIButton *msgBtn = [self.view viewWithTag:2];
    [msgBtn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    msgBtn.backgroundColor = UIColor.redColor;
    msgBtn.enabled = NO;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:nil];
    NSString *time = [dic objectForKey:@"time"];
    NSString *from = [dic objectForKey:@"from"];
    NSString *Id = [dic objectForKey:@"fromId"];
    NSString *type = [dic objectForKey:@"type"];
    NSString *body = [dic objectForKey:@"body"];
    if ([type isEqualToString:@"string"]) {
        NSString *msg = [NSString stringWithFormat:@"%@ %@\n%@", time, from, body];
        APPCODE;
        UIAlertController *alert = [app getMsgBox:msg
                                                 :^(UIAlertAction *action) {
                                                     [self alertListCheck];
                                                 }];
        if (self.presentFlg) {
            [self.alertList addObject:alert];
        } else {
            self.presentFlg = 1;
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    if ([type isEqualToString:@"locationStart"]) {
        if (CLLocationCoordinate2DIsValid(self.xyGps)) {
            [self locationSend:self.xyGps :Id];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (kCLAuthorizationStatusAuthorizedWhenInUse == status) {
        [self.locationManager startUpdatingLocation];
    } else if (kCLAuthorizationStatusNotDetermined == status) {
        // sys will pop up select box
    } else {
        self.presentFlg = 1;
        APPCODE;
        UIAlertController *alert = [app getMsgBox:@"Check location permission in device settings"
                                                 :^(UIAlertAction *action) {
                                                     [self alertListCheck];
                                                 }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.xyGps = [[locations lastObject] coordinate];
    [self locationSend:[[locations lastObject] coordinate] :@""];
}

-(void)locationSend:(CLLocationCoordinate2D)xy :(NSString *)toId {
    NSLog(@"didUpdateLocations %lf %lf", xy.latitude, xy.longitude);
    [self messageSend:[self xy2Dic:xy] :toId];
}

- (void)alertListCheck {
    if (self.alertList.count) {
        self.presentFlg = 1;
        UIAlertController *obj = self.alertList.firstObject;
        [self presentViewController:obj
                           animated:YES
                         completion:nil];
        [self.alertList removeObject:obj];
    } else {
        self.presentFlg = 0;
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (self != viewController) { // back to other page
        [self messageSend:[self xy002Dic] :@""];
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1];
        self.locationManager.delegate = nil;
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}

- (void)delayMethod {
    self.webSocket.delegate = nil;
    [self.webSocket close];
    self.webSocket = nil;
}

@end
