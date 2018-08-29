//
//  VCCheckIn.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface VCCheckIn : UIViewController<SRWebSocketDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate>
@property (readwrite, nonatomic)int type;
@property (readwrite, nonatomic)int presentFlg;
@property (readwrite, nonatomic)NSMutableArray *userListContent;
@property (readwrite, nonatomic)SRWebSocket *webSocket;
@property (readwrite, nonatomic)CLLocationManager *locationManager;
@property (readwrite, nonatomic)NSMutableArray *alertList;
@property (readwrite, nonatomic)CLLocationCoordinate2D xyGps;
@end
