//
//  AppDelegate.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    ViewController *vc = [[ViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    [navi.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navi.navigationBar.shadowImage = [UIImage new];
    self.window.rootViewController = navi;
    self.strServer = [[NSString alloc] initWithFormat:@"%@", [self getServer:SERVER]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)openActivity
{
    [self closeActivity];
    UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
    self.popDoing = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.popDoing setFrame:CGRectMake(0, 0, LINEH, LINEH)];
    [self.popDoing setCenter:navi.view.center];
    [self.popDoing startAnimating];
    [navi.topViewController.view addSubview:self.popDoing];
}

- (void)closeActivity
{
    if (self.popDoing) {
        [self.popDoing removeFromSuperview];
    }
}

- (NSString *)getServer:(NSString *)str
{
    NSRange range1 = [SERVER rangeOfString:@"//"];
    NSString *ip1 = [SERVER substringFromIndex:range1.location + 2];
    NSRange range2 = [ip1 rangeOfString:@":"];
    NSString *ip2 = [ip1 substringToIndex:range2.location];
    return ip2;
}

- (NSString *)setServer:(NSString *)str
{
    NSRange range1 = [str rangeOfString:@"//"];
    NSString *ip11 = [str substringToIndex:range1.location + 2];
    NSString *ip1 = [str substringFromIndex:range1.location + 2];
    NSRange range2 = [ip1 rangeOfString:@":"];
    NSString *ip2 = [ip1 substringFromIndex:range2.location];
    NSString *ip22 = [[NSString alloc] initWithFormat:@"%@%@%@", ip11, self.strServer, ip2];
    return ip22;
}

- (UIAlertController *)getMsgBox:(NSString *)msg
                                :(void (^)(UIAlertAction *action))handler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:handler];
    [alert addAction:okAction];
    return alert;
}

@end
