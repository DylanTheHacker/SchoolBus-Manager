//
//  VCJoinBus.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCJoinBus.h"

@interface VCJoinBus ()

@end

@implementation VCJoinBus

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Join Bus";
    UITextField *search = [[UITextField alloc]initWithFrame:
                           CGRectMake(LINEH, TOPH + LINEH / 2, SCREENW - 2 * LINEH, LINEH)];
    search.borderStyle = UITextBorderStyleRoundedRect;
    search.clearButtonMode = UITextFieldViewModeAlways;
    search.delegate = self;
    search.autocapitalizationType = UITextAutocapitalizationTypeNone;
    search.placeholder = @"busID";
    [self.view addSubview:search];
    [search addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIScrollView *busList = [[UIScrollView alloc]initWithFrame:
                             CGRectMake(0, TOPH + 2 * LINEH, SCREENW, SCREENH - (TOPH + 2 * LINEH) - 3 * LINEH)];
    busList.tag = -1;
    [self.view addSubview:busList];
    self.busListContent = [[NSMutableArray alloc] init];
    self.busListContentFilter = [[NSMutableArray alloc] init];
    
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/GetAllVehicles.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"ParentID":app.strUser,
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
                                        self.busListContent = [dic objectForKey:@"AllVehiclesArray"];
                                        if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                        if ([ret isEqualToString:@"2601"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2602"]) msg = @"";
                                        //if ([ret isEqualToString:@"2603"]) msg = @"";
                                        if ([ret isEqualToString:@"2604"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"2605"]) msg = @"";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            [self updateBusList:@""];
                                        } else {
                                            UIAlertController *alert = [app getMsgBox:msg :nil];
                                            [self presentViewController:alert animated:YES completion:nil];
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

-(void)busClick:(UIButton *)sender
{
    UIScrollView *busList = [self.view viewWithTag:-1];
    UIButton *bus = [busList viewWithTag:sender.tag];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:bus.currentTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.placeholder = @"password";
        textField.secureTextEntry = YES;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                UITextField *password = alert.textFields[0];
                                                if (password.text.length) {
                                                    NSMutableString *busItem = self.busListContentFilter[sender.tag - 1];
                                                    NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                options:NSJSONReadingMutableContainers
                                                                                                                  error:nil];
                                                    NSString *busID = [info objectForKey:@"BusID"];
                                                    [self joinBus:busID :password.text];
                                                } else {
                                                    APPCODE;
                                                    UIAlertController *alert = [app getMsgBox:@"cannot be empty" :nil];
                                                    [self presentViewController:alert animated:YES completion:nil];
                                                }
                                            }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)joinBus:(NSString *)bus :(NSString *)pw
{
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/UploadParentAddVehicle.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"ParentID":app.strUser,
                           @"BusID":bus,
                           @"BusPWD":pw,
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
                                        if ([ret isEqualToString:@"2801"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"2802"]) msg = @"";
                                        //if ([ret isEqualToString:@"2803"]) msg = @"";
                                        if ([ret isEqualToString:@"2804"]) msg = @"token error";
                                        if ([ret isEqualToString:@"2805"]) msg = @"password error";
                                        if ([ret isEqualToString:@"2806"]) msg = @"bus db error";
                                        if ([ret isEqualToString:@"2807"]) msg = @"user db error";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            [self.pParentBus updateMyBus];
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

-(void)updateBusList:(NSString *)strKey
{
    UIScrollView *busList = [self.view viewWithTag:-1];
    [busList.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.busListContentFilter removeAllObjects];
    int tagBus = 0;
    for (NSMutableString *busItem in self.busListContent) {
        NSMutableDictionary *info = [NSJSONSerialization JSONObjectWithData:[busItem dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        NSString *strBusID = [info objectForKey:@"BusID"];
        NSString *strBusName = [info objectForKey:@"BusName"];
        if ([strBusID isEqualToString:@""]) {
            continue;
        }
        UIButton *bus = [UIButton buttonWithType:UIButtonTypeCustom];
        bus.clipsToBounds = YES;
        bus.layer.cornerRadius = LINEH / 4;
        bus.tag = tagBus + 1;
        bus.frame = CGRectMake(LINEH, LINEH / 2 + tagBus * 3 * LINEH / 2, SCREENW - 2 * LINEH, LINEH);
        bus.backgroundColor = BTN_COLOR;
        [bus setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [bus setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
        NSString *buttonLabel = [[NSString alloc] initWithFormat:@"%@", strBusName.length?strBusName:strBusID];
        if (strKey.length && NSNotFound == [buttonLabel rangeOfString:strKey].location) {
            continue;
        }
        [self.busListContentFilter addObject:busItem];
        [bus setTitle:buttonLabel forState:UIControlStateNormal];
        [bus addTarget:self action:@selector(busClick:) forControlEvents:UIControlEventTouchUpInside];
        [busList addSubview:bus];
        tagBus++;
    }
    busList.contentSize = CGSizeMake(busList.frame.size.width, LINEH / 2 + tagBus * 3 * LINEH / 2);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [self updateBusList:textField.text];
}

@end
