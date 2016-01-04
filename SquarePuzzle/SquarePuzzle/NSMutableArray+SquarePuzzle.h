//
//  NSMutableArray+SquarePuzzle.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SquareBlock.h"

@class SquareUnit;
@interface NSMutableArray (SquarePuzzle)
+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(int)width height:(int)height;
@end
