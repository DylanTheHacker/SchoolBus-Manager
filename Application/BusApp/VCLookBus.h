//
//  VCLookBus.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface VCLookBus : UIViewController<SRWebSocketDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate, MKMapViewDelegate>
//@property (readwrite, nonatomic)int type;
@property (readwrite, nonatomic)int absentFlg;
@property (readwrite, nonatomic)int presentFlg;
@property (readwrite, nonatomic)int regionFlg;
@property (readwrite, nonatomic)SRWebSocket *webSocket;
@property (readwrite, nonatomic)CLLocationManager *locationManager;
@property (readwrite, nonatomic)NSMutableArray *alertList;
@property (readwrite, nonatomic)MKPointAnnotation *busAnn;
@property (readwrite, nonatomic)CLLocationCoordinate2D xyMap, xyGps;
@property (readwrite, nonatomic)MKPolyline *busAnnLine;
@property (readwrite, nonatomic)NSString *strFinalPath;
@end
