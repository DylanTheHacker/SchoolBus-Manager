//
//  VCSetting.m
//  BusApp
//
//  Created by macOS on 2017/8/10.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCSetting.h"

@interface VCSetting ()

@end

@implementation VCSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.delegate = self;
    self.title = @"Setting";
    UITextField *server = [[UITextField alloc]initWithFrame:
                           CGRectMake(SCREENW / 4, SCREENH / 2 - 3 * LINEH, SCREENW / 2, LINEH)];
    server.tag = 1;
    server.borderStyle = UITextBorderStyleRoundedRect;
    server.delegate = self;
    server.autocapitalizationType = UITextAutocapitalizationTypeNone;
    server.placeholder = @"server ip";
    [self.view addSubview:server];
    APPCODE;
    server.text = app.strServer;
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

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    if (self != viewController) { // back to other page
        UITextField *server = [self.view viewWithTag:1];
        if (server.text.length) {
            APPCODE;
            app.strServer = [[NSString alloc] initWithFormat:@"%@", server.text];
        }
    }
}

@end
