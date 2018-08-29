//
//  VCEnroll.h
//  BusApp
//
//  Created by macOS on 2017/7/11.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"

@interface VCEnroll : UIViewController<UITextFieldDelegate, RadioButtonDelegate>
@property (readwrite, nonatomic)int type;
@end
