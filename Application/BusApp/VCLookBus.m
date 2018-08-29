//
//  VCLookBus.m
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "AppDelegate.h"
#import "VCLookBus.h"

@interface VCLookBus ()

@end

@implementation VCLookBus

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREENW, SCREENH)];
    [imageView setImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:imageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.presentFlg = 0;
    self.navigationController.delegate = self;
    self.title = @"Monitor";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = LINEH / 4;
    button.tag = 1;
    button.frame = CGRectMake(8, SCREENH - 2 * LINEH, SCREENW / 2 - 12, LINEH);
    button.backgroundColor = BTN_COLOR;
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(absentClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    msgBtn.clipsToBounds = YES;
    msgBtn.layer.cornerRadius = LINEH / 4;
    msgBtn.tag = 2;
    msgBtn.frame = CGRectMake(SCREENW / 2 + 4, SCREENH - 2 * LINEH, SCREENW / 2 - 12, LINEH);
    msgBtn.backgroundColor = BTN_COLOR;
    [msgBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [msgBtn setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [msgBtn setTitle:@"Message driver" forState:UIControlStateNormal];
    [msgBtn addTarget:self action:@selector(messageClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:msgBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREENW / 4, SCREENH - 3 * LINEH - 8, SCREENW / 2, LINEH)];
    label.tag = 3;
    label.backgroundColor = [UIColor colorWithWhite:.5 alpha:0.5];
    [self.view addSubview:label];
    [self disEstimate:@-1];
    
    self.regionFlg = 0;
    self.xyMap = self.xyGps = kCLLocationCoordinate2DInvalid;
    self.busAnnLine = nil;
    MKMapView *mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, TOPH, SCREENW, SCREENH - TOPH)];
    mapView.delegate = self;
    mapView.tag = -1;
    mapView.showsUserLocation = YES;
    [self.view addSubview:mapView];
    [self.view insertSubview:mapView aboveSubview:imageView];
    self.busAnn = [[MKPointAnnotation alloc]init];
    self.busAnn.coordinate = kCLLocationCoordinate2DInvalid;
    [mapView addAnnotation:self.busAnn];
    
    self.alertList = [[NSMutableArray alloc] init];
    
    //self.type = 1; // enable location sharing
    [self chkUserStatus];
    APPCODE;
    NSString *strWs = [NSString stringWithFormat:@"%@%@", [app setServer:SERVER_WS], app.strUser];
    NSURL *urlWs = [NSURL URLWithString:strWs];
    self.webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:urlWs]];
    self.webSocket.delegate = self;
    [self.webSocket open];

    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strPath = [pathArr lastObject];
    self.strFinalPath = [NSString stringWithFormat:@"%@/myfile.txt", strPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:self.strFinalPath]) {
        [[self addTail2Str:self.strFinalPath] writeToFile:self.strFinalPath
                                               atomically:YES
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    }
}

- (NSString *)addTail2Str:(NSString *)val
{
    NSString *ret = [NSString stringWithFormat:@"%@\r\n", val];
    return ret;
}

- (void)disEstimate:(NSNumber *)val
{
    int ret = [val intValue];
    NSString *valS = nil;
    if (-1 == ret) {
        valS = [NSString stringWithFormat:@"Estimated time: --:--"];
    } else {
        valS = [NSString stringWithFormat:@"Estimated time: %02d:%02d", ret / 60, ret % 60];
    }
    UILabel *label = [self.view viewWithTag:3];
    label.text = valS;
}

- (void)doEstimateProc:(NSString *)val
{
    int ret = -1;
    // estimate processing
    //NSLog(@"all pos [%@]", val);
    NSMutableArray *lst = [val componentsSeparatedByString:@"\r\n"];
    if (2 < lst.count) {
        [lst removeLastObject];
        [lst removeObjectAtIndex:0];
        ret = [self dataFunc:lst];
    }
    NSNumber *param = [NSNumber numberWithInt:ret];
    [self performSelectorOnMainThread:@selector(disEstimate:) withObject:param waitUntilDone:YES];
}

- (void)doEstimate
{
    // read from file then close
    NSString *param = [[NSString alloc]initWithContentsOfFile:self.strFinalPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    [self performSelectorInBackground:@selector(doEstimateProc:) withObject:param];
}

- (void)addNewData2File:(NSString *)val
{
    //NSLog(@"add pos [%@]", val);
    // write to file then close
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.strFinalPath];
    [fileHandle seekToEndOfFile];
    NSData* stringData = [[self addTail2Str:val] dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
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

-(void)chkUserStatus
{
    APPCODE;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSDate *datenow = [NSDate date];
    NSString *dateString = [formatter stringFromDate:datenow];
    [self chkUserStatusProc:app.strUser :dateString :1];
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
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                            UIButton *button = [self.view viewWithTag:tag];
                                            if ([status isEqualToString:@"true"]) {
                                                [button setTitle:@"Absence Confirmed" forState:UIControlStateNormal];
                                                self.absentFlg = 1;
                                                //self.type = 0; // disable location sharing
                                            } else {
                                                [button setTitle:@"Confirm Absence" forState:UIControlStateNormal];
                                                self.absentFlg = 0;
                                            }
                                        } else {
                                            self.presentFlg = 1;
                                            UIAlertController *alert = [app getMsgBox:msg
                                                                                     :^(UIAlertAction *action) {
                                                                                         [self alertListCheck];
                                                                                     }];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(void)absentClick:(UIButton *)sender
{
    self.absentFlg = 1 - self.absentFlg;
    UIButton *button = [self.view viewWithTag:1];
    if (self.absentFlg) {
        [button setTitle:@"Absence Confirmed" forState:UIControlStateNormal];
        //self.type = 0; // disable location sharing
    } else {
        [button setTitle:@"Confirm Absence" forState:UIControlStateNormal];
        //self.type = 1; // enable location sharing
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSDate *datenow = [NSDate date];
    NSString *dateString = [formatter stringFromDate:datenow];
    APPCODE;
    NSString *str = [NSString stringWithFormat:@"%@/UploadAbsentState.ashx", [app setServer:SERVER]];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *json = @{
                           @"AccessToken":app.strToken,
                           @"ParentID":app.strUser,
                           @"CurrentDate":dateString,
                           @"AbsentState":self.absentFlg?@"true":@"false",
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
                                        if ([ret isEqualToString:@"3001"]) msg = @"json error";
                                        //if ([ret isEqualToString:@"3002"]) msg = @"";
                                        //if ([ret isEqualToString:@"3003"]) msg = @"";
                                        if ([ret isEqualToString:@"3004"]) msg = @"token error";
                                        //if ([ret isEqualToString:@"3005"]) msg = @"";
                                        //if ([ret isEqualToString:@"3006"]) msg = @"";
                                        //if ([ret isEqualToString:@"3007"]) msg = @"";
                                    } else {
                                        msg = @"network error";
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [app closeActivity];
                                        if ([ret isEqualToString:@"0000"]) {
                                        } else {
                                            self.presentFlg = 1;
                                            UIAlertController *alert = [app getMsgBox:msg
                                                                                     :^(UIAlertAction *action) {
                                                                                         [self alertListCheck];
                                                                                     }];
                                            [self presentViewController:alert animated:YES completion:nil];
                                        }
                                    });
                                }];
    [go resume];
    [app openActivity];
}

-(void)messageClick:(UIButton *)sender
{
#if 0
    [self addNewData2File:@"2018-01-01 12:34:56 10.000000 100.000000 0"];
    [self doEstimate];
#else
    APPCODE;
    NSRange range = [app.strBus rangeOfString:@"_bus"];
    NSString *toUser = [[NSString alloc] initWithFormat:@"%@", [app.strBus substringToIndex:range.location]];
    [self messageSendToUser:toUser];
#endif
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

-(NSMutableDictionary *)xy002Dic
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setValue:@"locationStart" forKey:@"type"];
    [dic setValue:@"" forKey:@"body"];
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
    //NSString *Id = [dic objectForKey:@"fromId"];
    NSString *type = [dic objectForKey:@"type"];
    NSString *body = [dic objectForKey:@"body"];
    if ([type isEqualToString:@"string"]
        || [type isEqualToString:@"aboardYes"]
        || [type isEqualToString:@"aboardYet"]) {
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
        //if ([type isEqualToString:@"aboardYes"]) self.type = 0; // disable location sharing
        //if ([type isEqualToString:@"aboardYet"]) self.type = 1; // enable location sharing
    }
    if ([type isEqualToString:@"location"]) {
        if (CLLocationCoordinate2DIsValid(self.xyMap)
            && CLLocationCoordinate2DIsValid(self.xyGps)) {
            CLLocationCoordinate2D xy;
            sscanf([body UTF8String], "%lf %lf", &xy.latitude, &xy.longitude);
            NSLog(@"didUpdateLocations %lf %lf", xy.latitude, xy.longitude);
            self.busAnn.coordinate =
            CLLocationCoordinate2DMake(xy.latitude + (self.xyMap.latitude - self.xyGps.latitude),
                                       xy.longitude + (self.xyMap.longitude - self.xyGps.longitude));
            [self drawLine];
            
            NSString *item = [NSString stringWithFormat:@"%@ %@ 1", time, body];
            [self addNewData2File:item];
            [self doEstimate];
        }
    }
    if ([type isEqualToString:@"locationStop"]) { // stop location sharing
        NSLog(@"stopUpdateLocations");
        self.busAnn.coordinate = kCLLocationCoordinate2DInvalid;
        [self drawLine];
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
    [self drawLine];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.xyMap = userLocation.coordinate;
    if (0 == self.regionFlg) {
        self.regionFlg = 1;
        MKCoordinateSpan span = {.02, .02};
        MKCoordinateRegion rc;
        rc.span = span;
        rc.center = self.xyMap;
        mapView.region = rc;
    }
    [self drawLine];
    // want bus location
    APPCODE;
    NSRange range = [app.strBus rangeOfString:@"_bus"];
    NSString *toUser = [[NSString alloc] initWithFormat:@"%@", [app.strBus substringToIndex:range.location]];
    [self messageSend:[self xy002Dic] :toUser];
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    MKAnnotationView *annotationView = views[0];
    annotationView.canShowCallout = NO;
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
        self.webSocket.delegate = nil;
        [self.webSocket close];
        self.webSocket = nil;
        self.locationManager.delegate = nil;
        [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
}

- (void)drawLine {
    MKMapView *mapView = [self.view viewWithTag:-1];
    if (self.busAnnLine) {
        [mapView removeOverlay:self.busAnnLine];
        self.busAnnLine = nil;
    }
    if (CLLocationCoordinate2DIsValid(self.xyMap)
        && CLLocationCoordinate2DIsValid(self.xyGps)
        && CLLocationCoordinate2DIsValid(self.busAnn.coordinate)) {
        CLLocationCoordinate2D coordinateArray[2];
        coordinateArray[0] = self.busAnn.coordinate;
        coordinateArray[1] = mapView.userLocation.coordinate;
        self.busAnnLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
        [mapView addOverlay:self.busAnnLine];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *overlayRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        overlayRenderer.strokeColor = BTN_COLOR;
        overlayRenderer.lineWidth = 2;
        overlayRenderer.lineDashPhase = 2;
        overlayRenderer.lineDashPattern = @[@2, @5];
        return overlayRenderer;
    }
    return nil;
}

- (int)dataFunc:(NSMutableArray *)val
{
    NSLog(@"My Location %lf %lf", self.xyGps.latitude, self.xyGps.longitude);
    NSMutableArray *lst = [[NSMutableArray alloc] init];
    for (int i = 0; i < val.count; i++) {
        // 2018-01-01 12:34:56 10.000000 100.000000 1
        NSLog(@"[1][%d][%@]\n", i, val[i]);
        NSString *item = val[i];
        NSMutableArray *items = [item componentsSeparatedByString:@" "];
        if (5 == items.count && [@"1" isEqual:items[4]]) {
            [items removeLastObject];
            [lst addObject:items];
        }
    }
    if (lst.count) {
        NSMutableArray *timestamp = lst[lst.count - 1];
        NSMutableArray *today = [[NSMutableArray alloc] init];
        NSMutableArray *history = [[NSMutableArray alloc] init];
        for (int i = 0; i < lst.count; i++) {
            NSLog(@"[2][%d][%@]\n", i, lst[i]);
            int sel = [self dataSel:timestamp :lst[i]];
            if (1 == sel) {
                NSLog(@"small path\n");
                [today addObject:lst[i]];
            } else if (2 == sel) {
                NSLog(@"big path\n");
                [history addObject:lst[i]];
            } else { // 0 == sel
                NSLog(@"unused\n");
            }
        }
        if (2 <= today.count && 2 <= history.count) {
            double today_dist = [self calcdist:today];
            if (0 < today_dist) {
                int route_dist_min_offset = 0;
                int route_dist_min_len = 0;
                double route_dist_min = 0;
                for (int i = 0; i < history.count - 1; i++) {
                    NSMutableArray *section = [self selsection:history :i :today_dist];
                    double route_dist = [self calc2routes:section :today];
                    if (0 == route_dist_min || route_dist < route_dist_min) {
                        route_dist_min = route_dist;
                        route_dist_min_offset = i;
                        route_dist_min_len = section.count;
                    }
                }
                NSLog(@"found: [%d][%d]\n", route_dist_min_offset, route_dist_min_len);
                return [self calctime:history
                                     :route_dist_min_offset
                                     :route_dist_min_offset + route_dist_min_len
                                     :self.xyGps];
            }
        }
    }
    return -1;
}

- (int)dataSel:(NSMutableArray *)want :(NSMutableArray *)item
{
    if (4 == want.count && 4 == item.count) {
        int ymd1 = [self str2int:want[0] :1];
        int hms1 = [self str2int:want[1] :2];
        int ymd2 = [self str2int:item[0] :1];
        int hms2 = [self str2int:item[1] :2];
        if (hms1 < 120000 && hms2 < 120000) { // am
            if (ymd1 <= ymd2) { // actually ymd1 == ymd2
                return 1; // today
            } else {
                return 2; // yesterday and before
            }
        }
        if (120000 < hms1 && 120000 < hms1) { // pm
            if (ymd1 <= ymd2) {
                return 1;
            } else {
                return 2;
            }
        }
    }
    return 0;
}

- (int)str2int:(NSString *)str :(int)type
{
    int a1 = 0, a2 = 0, a3 = 0;
    if (1 == type) { // "2018-01-01" to 20180101
        sscanf([str UTF8String], "%d-%d-%d", &a1, &a2, &a3);
        return 10000 * a1 + 100 * a2 + a3;
    }
    if (2 == type) { // "12:34:56" to 123456
        sscanf([str UTF8String], "%d:%d:%d", &a1, &a2, &a3);
        return 10000 * a1 + 100 * a2 + a3;
    }
    return 0;
}

- (double)calcdist:(NSMutableArray *)lst
{
    double total = 0;
    for (int i = 0; i < lst.count - 1; i++) {
        NSMutableArray *lst1 = lst[i];
        NSMutableArray *lst2 = lst[i + 1];
        double points_dist = [self calc2points:lst1 :lst2];
        total += points_dist;
    }
    return total;
}

- (NSMutableArray *)selsection:(NSMutableArray *)lst :(int)offset :(double)dist
{
    NSMutableArray *item = lst[offset];
    int ymd = [self str2int:item[0] :1];
    NSMutableArray *section = [[NSMutableArray alloc] init];
    double total = 0;
    for (int i = 0; i < lst.count - 1; i++) {
        int ymd_item = [self str2int:item[0] :1];
        NSMutableArray *lst1 = lst[i];
        NSMutableArray *lst2 = lst[i + 1];
        double points_dist = [self calc2points:lst1 :lst2];
        total += points_dist;
        if (total < dist && ymd_item == ymd) {
            [section addObject:lst[i]];
        } else {
            break; // distance is enough or time break
        }
    }
    return section;
}

- (double)calc2points:(NSMutableArray *)point1 :(NSMutableArray *)point2
{
    //NSLog(@"%s %@\n", __FUNCTION__, point1);
    //NSLog(@"%s %@\n", __FUNCTION__, point2);
    NSString *gps1sx = point1[2];
    NSString *gps1sy = point1[3];
    NSString *gps2sx = point2[2];
    NSString *gps2sy = point2[3];
    CLLocationCoordinate2D gps1, gps2;
    sscanf([gps1sx UTF8String], "%lf", &gps1.latitude);
    sscanf([gps1sy UTF8String], "%lf", &gps1.longitude);
    sscanf([gps2sx UTF8String], "%lf", &gps2.latitude);
    sscanf([gps2sy UTF8String], "%lf", &gps2.longitude);
    CLLocation *gps1_l = [[CLLocation alloc] initWithLatitude:gps1.latitude longitude:gps1.longitude];
    CLLocation *gps2_l = [[CLLocation alloc] initWithLatitude:gps2.latitude longitude:gps2.longitude];
    CLLocationDistance meters = [gps1_l distanceFromLocation:gps2_l];
    return meters;
}

- (double)calc1points1gps:(NSMutableArray *)point1 :(CLLocationCoordinate2D)point2
{
    NSString *gps1sx = point1[2];
    NSString *gps1sy = point1[3];
    CLLocationCoordinate2D gps1;
    sscanf([gps1sx UTF8String], "%lf", &gps1.latitude);
    sscanf([gps1sy UTF8String], "%lf", &gps1.longitude);
    CLLocation *gps1_l = [[CLLocation alloc] initWithLatitude:gps1.latitude longitude:gps1.longitude];
    CLLocation *gps2_l = [[CLLocation alloc] initWithLatitude:point2.latitude longitude:point2.longitude];
    CLLocationDistance meters = [gps1_l distanceFromLocation:gps2_l];
    return meters;
}

- (double)calc2routes:(NSMutableArray *)route1 :(NSMutableArray *)route2
{
    double T12 = 0, T21 = 0;
    for (int i = 0; i < route1.count; i++) {
        NSMutableArray *item = route1[i];
        double pT1 = [self calc_pT:item :route2];
        double T1 = [self calcdist:route1];
        if (0 < T1) {
            T12 = pT1 / T1;
        }
    }
    for (int i = 0; i < route2.count; i++) {
        NSMutableArray *item = route2[i];
        double pT2 = [self calc_pT:item :route1];
        double T2 = [self calcdist:route2];
        if (0 < T2) {
            T21 = pT2 / T2;
        }
    }
    return (T12 + T21) / 2;
}

- (double)calc_pT:(NSMutableArray *)point :(NSMutableArray *)route
{
    double dist_min = 0;
    for (int i = 0; i < route.count; i++) {
        NSMutableArray *item = route[i];
        double points_dist = [self calc2points:point :item];
        if (0 == dist_min || points_dist < dist_min) {
            dist_min = points_dist;
        }
    }
    return dist_min;
}

- (int)calctime:(NSMutableArray *)lst :(int)up :(int)dn :(CLLocationCoordinate2D)my
{
    NSMutableArray *item = lst[up];
    int ymd = [self str2int:item[0] :1];
    int up_dist_min_offset = 0, dn_dist_min_offset = 0;
    double up_dist_min = 0, dn_dist_min = 0;
    for (int i = up; 0 <= i; i--) {
        NSMutableArray *up_item = lst[i];
        int up_ymd = [self str2int:item[0] :1];
        double up_points_dist = [self calc1points1gps:up_item :my];
        if ((0 == up_dist_min || up_points_dist < up_dist_min) && up_ymd == ymd) {
            up_dist_min = up_points_dist;
            up_dist_min_offset = i;
        } else {
            break;
        }
    }
    for (int i = dn; i < lst.count; i++) {
        NSMutableArray *dn_item = lst[i];
        int dn_ymd = [self str2int:item[0] :1];
        double dn_points_dist = [self calc1points1gps:dn_item :my];
        if ((0 == dn_dist_min || dn_points_dist < dn_dist_min) && dn_ymd == ymd) {
            dn_dist_min = dn_points_dist;
            dn_dist_min_offset = i;
        } else {
            break;
        }
    }
    NSMutableArray *timestamp1 = nil, *timestamp2 = nil;
    if (up_dist_min < dn_dist_min) {
        // D-value of lst[up_dist_min_offset] lst[up]
        timestamp1 = lst[up_dist_min_offset];
        timestamp2 = lst[up];
    } else {
        // D-value of lst[dn_dist_min_offset] lst[dn]
        timestamp1 = lst[dn_dist_min_offset];
        timestamp2 = lst[dn];
    }
    NSString *hms1 = timestamp1[1];
    NSString *hms2 = timestamp2[1];
    return [self calctime:hms1 :hms2];
}

- (int)calctime:(NSString *)starTime :(NSString *)endTime
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"hh:mm:ss"];
    NSDate *startDate = [formater dateFromString:starTime];
    NSDate *endDate = [formater dateFromString:endTime];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time; // second
}

@end
