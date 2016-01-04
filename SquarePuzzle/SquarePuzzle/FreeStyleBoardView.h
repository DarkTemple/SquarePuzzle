//
//  FreeStyleBoardView.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SquareBlock.h"

@interface FreeStyleBoardView : UIView

- (instancetype)initWithBlocks:(NSArray <SquareBlock *> *)blocks;

@end
