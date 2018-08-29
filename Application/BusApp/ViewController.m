//
//  ViewController.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "VCMyBus.h"
#import "VCEnroll.h"
#import "VCHelp.h"
#import "VCSetting.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSThread sleepForTimeInterval:(2)];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    imageView.userInteractionEnabled = YES;
    imageView.tag = 100;
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"SchoolBus Manager";
    UITextField *user = [[UITextField alloc]initWithFrame:
                         CGRectMake(SCREENW / 4, SCREENH / 2 - 3 * LINEH, SCREENW / 2, LINEH)];
    user.tag = 1;
    user.borderStyle = UITextBorderStyleRoundedRect;
    user.clearButtonMode = UITextFieldViewModeAlways;
    user.delegate = self;
    user.autocapitalizationType = UITextAutocapitalizationTypeNone;
    user.placeholder = @"userID";
    UITextField *password = [[UITextField alloc]initWithFrame:
                             CGRectMake(SCREENW / 4, SCREENH / 2 - 3 * LINEH / 2, SCREENW / 2, LINEH)];
    password.tag = 2;
    password.borderStyle = UITextBorderStyleRoundedRect;
    password.clearButtonMode = UITextFieldViewModeAlways;
    password.delegate = self;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.placeholder = @"password";
    password.secureTextEntry = YES;
    UIButton *login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.clipsToBounds = YES;
    login.layer.cornerRadius = LINEH / 4;
    login.frame = CGRectMake(SCREENW / 4, SCREENH / 2, SCREENW / 2, LINEH);
    login.backgroundColor = BTN_COLOR;
    [login setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [login setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [login setTitle:@"Login" forState:UIControlStateNormal];
    [login addTarget:self action:@selector(loginClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *enroll = [UIButton buttonWithType:UIButtonTypeCustom];
    enroll.clipsToBounds = YES;
    enroll.layer.cornerRadius = LINEH / 4;
    enroll.frame = CGRectMake(SCREENW / 4, SCREENH / 2 + 3 * LINEH / 2, SCREENW / 2, LINEH);
    enroll.backgroundColor = BTN_COLOR;
    [enroll setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [enroll setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [enroll setTitle:@"Register" forState:UIControlStateNormal];
    [enroll addTarget:self action:@selector(enrollClick:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *help = [UIButton buttonWithType:UIButtonTypeCustom];
    help.frame = CGRectMake(SCREENW / 2 - LINEH / 2, SCREENH - TOPH / 2 - LINEH / 2, LINEH, LINEH);
    [help setImage:[UIImage imageNamed:@"help"] forState:UIControlStateNormal];
    [help addTarget:self action:@selector(helpClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:user];
    [self.view addSubview:password];
    [self.view addSubview:login];
    [self.view addSubview:enroll];
    [self.view addSubview:help];
    self.type = 0;
    
    user.text = @"P123";
    password.text = @"123";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)loginClick:(UIButton *)sender
{
    UITextField *user = [self.view viewWithTag:1];
    UITextField *password = [self.view viewWithTag:2];
    APPCODE;
    if (user.text.length && password.text.length) {
        NSString *str = [NSString stringWithFormat:@"%@/login.ashx", [app setServer:SERVER]];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.HTTPMethod = @"POST";
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *json = @{
                               @"userid":user.text,
                               @"userpwd":password.text,
                               };
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
        urlRequest.HTTPBody = data;
        NSURLSession *urlSession = [NSURLSession sharedSession];
        NSURLSessionDataTask *go = [urlSession
                                    dataTaskWithRequest:urlRequest
                                    completionHandler:^(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error) {
                                        NSString *msg = @"Incorrect input";
                                        NSString *ret = @"";
                                        NSString *token = @"";
                                        NSString *name = @"";
                                        NSString *type = @"";
                                        if (nil == error) {
                                            NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                                       options:NSJSONReadingMutableContainers
                                                                                                         error:nil];
                                            ret = [dic objectForKey:@"ResultCode"];
                                            token = [dic objectForKey:@"AccessToken"];
                                            name = [dic objectForKey:@"Username"];
                                            type = [dic objectForKey:@"Role"];
                                            if ([ret isEqualToString:@"0000"]) msg = @"ok";
                                            //if ([ret isEqualToString:@"2101"]) msg = @"";
                                            //if ([ret isEqualToString:@"2102"]) msg = @"";
                                        } else {
                                            msg = @"network error";
                                        }
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [app closeActivity];
                                            if ([ret isEqualToString:@"0000"]) {
                                                app.strToken = [[NSString alloc] initWithFormat:@"%@", token];
                                                app.strName = [[NSString alloc] initWithFormat:@"%@", name];
                                                app.strUser = [[NSString alloc] initWithFormat:@"%@", user.text];
                                                VCMyBus *vc = [[VCMyBus alloc] init];
                                                vc.type = [type isEqualToString:@"driver"]?1:0;
                                                [self.navigationController pushViewController:vc animated:YES];
                                            } else {
                                                UIAlertController *alert = [app getMsgBox:msg :nil];
                                                [self presentViewController:alert animated:YES completion:nil];
                                            }
                                        });
                                    }];
        [go resume];
        [app openActivity];
    } else {
        UIAlertController *alert = [app getMsgBox:@"incomplete input" :nil];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)enrollClick:(UIButton *)sender
{
    VCEnroll *vc = [[VCEnroll alloc] init];
    vc.type = -1;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)helpClick:(UIButton *)sender
{
    VCHelp *vc = [[VCHelp alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if (100 == [touch view].tag)
    {
        CGRect rc1 = CGRectMake(0, TOPH, TOPH, TOPH);
        CGRect rc2 = CGRectMake(SCREENW - TOPH, TOPH, TOPH, TOPH);
        CGRect rc3 = CGRectMake(0, SCREENH - TOPH, TOPH, TOPH);
        CGRect rc4 = CGRectMake(SCREENW - TOPH, SCREENH - TOPH, TOPH, TOPH);
        CGPoint point = [touch locationInView:[touch view]];
        if (CGRectContainsPoint(rc1, point)) {
            if (0 == self.type) {
                self.type = 1;
            } else if (1 == self.type) {
            } else {
                self.type = 0;
            }
        } else if (CGRectContainsPoint(rc2, point)) {
            if (1 == self.type) {
                self.type = 2;
            } else if (2 == self.type) {
            } else {
                self.type = 0;
            }
        } else if (CGRectContainsPoint(rc3, point)) {
            if (2 == self.type) {
                self.type = 3;
            } else if (3 == self.type) {
            } else {
                self.type = 0;
            }
        } else if (CGRectContainsPoint(rc4, point)) {
            if (3 == self.type) {
                VCSetting *vc = [[VCSetting alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            self.type = 0;
        } else {
            self.type = 0;
        }
    }
}

@end
