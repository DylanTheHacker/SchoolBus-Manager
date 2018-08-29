//
//  AppDelegate.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VCMyBus.h"

#define SCREENW ([UIScreen mainScreen].bounds.size.width)
#define SCREENH ([UIScreen mainScreen].bounds.size.height)
#define TOPH    ([[UIApplication sharedApplication]statusBarFrame].size.height \
+ self.navigationController.navigationBar.frame.size.height)
#define LINEH   (30)
#define SERVER  (@"http://221.228.242.186:8080")
#define SERVER_WS   (@"ws://221.228.242.186:8080/WebsocketHandler.ashx?user=")
#define APPCODE     AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define BTN_COLOR   [UIColor colorWithRed:149/255.0 green:103/255.0 blue:60/255.0 alpha:1.0]
#define BG_COLOR    [UIColor colorWithRed:149/255.0 green:103/255.0 blue:60/255.0 alpha:.3]

@interface AppDelegate : UIResponder <UIApplicationDelegate>
- (void)openActivity;
- (void)closeActivity;
- (NSString *)setServer:(NSString *)str;
- (UIAlertController *)getMsgBox:(NSString *)msg
                                :(void (^)(UIAlertAction *action))handler;
@property (strong, nonatomic) UIActivityIndicatorView *popDoing;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *strToken;
@property (strong, nonatomic) NSString *strUser;
@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSString *strBus;
@property (strong, nonatomic) NSString *strServer;
//@property (strong, nonatomic) VCMyBus *vcMyBus;

@end
