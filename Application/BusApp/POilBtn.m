//
//  POilBtn.m
//  JustPress
//
//  Created by macOS on 2017/8/17.
//  Copyright © 2017年 macOS. All rights reserved.
//

#import "POilBtn.h"

@implementation POilBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addTarget:self action:@selector(backNormal:)
       forControlEvents:UIControlEventTouchUpInside
         | UIControlEventTouchUpOutside
         | UIControlEventTouchCancel];
        [self addTarget:self action:@selector(backHighlighted:)
       forControlEvents:UIControlEventTouchDown];
        [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    }
    return self;
}

- (void)backNormal:(UIButton *)sender
{
    sender.backgroundColor = self.backColorNormal;
}

- (void)backHighlighted:(UIButton *)sender
{
    sender.backgroundColor = self.backColorHighlighted;
}

@end
