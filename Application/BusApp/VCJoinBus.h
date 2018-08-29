//
//  VCJoinBus.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCMyBus.h"

@interface VCJoinBus : UIViewController<UITextFieldDelegate>
@property (readwrite, nonatomic)NSMutableArray *busListContent;
@property (readwrite, nonatomic)NSMutableArray *busListContentFilter;
@property (readwrite, nonatomic)VCMyBus *pParentBus;
@end
