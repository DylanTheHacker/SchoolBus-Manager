//
//  VCMyBus.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCMyBus : UIViewController<UITableViewDelegate, UITableViewDataSource>
-(void)updateMyBus;
@property (readwrite, nonatomic)int type;
@property (readwrite, nonatomic)NSMutableArray *busListContent;
@property (readwrite, nonatomic)NSMutableString *busListContentSel;
@end
