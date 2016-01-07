//
//  BlockView.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridUnitView.h"

@class SquareBlock;
@interface BlockView : UIView
@property (nonatomic) CGPoint startPoint;

- (instancetype)initWithSquare:(SquareBlock *)block gridWidth:(CGFloat)gridWidth;

@end
