//
//  GridUnitView.m
//  SquarePuzzle
//
//  Created by DarkTemple on 15/12/27.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "GridUnitView.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>

@implementation GridUnitView

- (instancetype)initWithColor:(UIColor *)color
{
    if (self = [super init]) {
        self.backgroundColor = color;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.layer.borderWidth = kLineWidth;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}

@end
