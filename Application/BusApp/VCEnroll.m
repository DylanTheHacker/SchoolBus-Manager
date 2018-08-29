//
//  VCEnroll.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCEnroll.h"

@interface VCEnroll ()

@end

@implementation VCEnroll

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Register";
    RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"group" index:0];
    RadioButton *rb2 = [[RadioButton alloc] initWithGroupId:@"group" index:1];
    rb1.frame = CGRectMake(SCREENW / 4, SCREENH / 2 + 4, LINEH, LINEH);
    rb2.frame = CGRectMake(SCREENW / 2, SCREENH / 2 + 4, LINEH, LINEH);
    [self.view addSubview:rb1];
    [self.view addSubview:rb2];
    [RadioButton addObserverForGroupId:@"group" observer:self];
    UILabel *label1 = [[UILabel alloc] initWithFrame:
                       CGRectMake(SCREENW / 4 + LINEH - 4, SCREENH / 2, SCREENW, LINEH)];
    label1.backgroundColor = UIColor.clearColor;
    label1.text = @"Parent";
    UILabel *label2 = [[UILabel alloc] initWithFrame:
                       CGRectMake(SCREENW / 2 + LINEH - 4, SCREENH / 2, SCREENW, LINEH)];
    label2.backgroundColor = UIColor.clearColor;
    label2.text = @"Driver";
    [self.view addSubview:label1];
    [self.view addSubview:label2];
    UITextField *name = [[UITextField alloc]initWithFrame:
                         CGRectMake(SCREENW / 4, SCREENH / 2 - 6 * LINEH, SCREENW / 2, LINEH)];
    name.tag = 3;
    name.borderStyle = UITextBorderStyleRoundedRect;
    name.clearButtonMode = UITextFieldViewModeAlways;
    name.delegate = self;
    name.autocapitalizationType = UITextAutocapitalizationTypeNone;
    name.placeholder = @"child's name";
    UITextField *addr = [[UITextField alloc]initWithFrame:
                         CGRectMake(SCREENW / 4, SCREENH / 2 - 9 * LINEH / 2, SCREENW / 2, LINEH)];
    addr.tag = 4;
    addr.borderStyle = UITextBorderStyleRoundedRect;
    addr.clearButtonMode = UITextFieldViewModeAlways;
    addr.delegate = self;
    addr.autocapitalizationType = UITextAutocapitalizationTypeNone;
    addr.placeholder = @"address";
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
    UIButton *enroll = [UIButton buttonWithType:UIButtonTypeCustom];
    enroll.clipsToBounds = YES;
    enroll.layer.cornerRadius = LINEH / 4;
    enroll.frame = CGRectMake(SCREENW / 4, SCREENH / 2 + 3 * LINEH / 2, SCREENW / 2, LINEH);
    enroll.backgroundColor = BTN_COLOR;
    [enroll setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [enroll setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [enroll setTitle:@"Register" forState:UIControlStateNormal];
    [enroll addTarget:self action:@selector(enrollClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:name];
    [self.view addSubview:addr];
    [self.view addSubview:user];
    [self.view addSubview:password];
    [self.view addSubview:enroll];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)enrollClick:(UIButton *)sender
{
    UITextField *user = [self.view viewWithTag:1];
    UITextField *password = [self.view viewWithTag:2];
    UITextField *name = [self.view viewWithTag:3];
    UITextField *addr = [self.view viewWithTag:4];
    APPCODE;
    if (0 <= self.type
        && user.text.length
        && password.text.length
        && name.text.length
        && addr.text.length) {
        NSString *str = [NSString stringWithFormat:@"%@/register.ashx", [app setServer:SERVER]];
        NSURL *url = [NSURL URLWithString:str];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.HTTPMethod = @"POST";
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary *json = @{
                               @"role":self.type?@"driver":@"parent",
                               @"userid":user.text,
                               @"username":name.text,
                               @"userpwd":password.text,
                               @"address":addr.text,
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
                                            //if ([ret isEqualToString:@"2001"]) msg = @"";
                                            if ([ret isEqualToString:@"2002"]) msg = @"user error";
                                            //if ([ret isEqualToString:@"2003"]) msg = @"";
                                            if ([ret isEqualToString:@"2004"]) msg = @"password error";
                                            //if ([ret isEqualToString:@"2005"]) msg = @"";
                                            if ([ret isEqualToString:@"2006"]) msg = @"user existed";
                                            //if ([ret isEqualToString:@"2007"]) msg = @"";
                                        } else {
                                            int a = error.code;//@"network error";
                                            a = a;
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
    } else {
        UIAlertController *alert = [app getMsgBox:@"incomplete input" :nil];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId
{
    self.type = (int)index;
}

@end
