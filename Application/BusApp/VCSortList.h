//
//  VCSortList.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCSortList : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (readwrite, nonatomic)NSMutableArray *userListContent;
@end
