//
//  NSMutableArray+SquarePuzzle.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "NSMutableArray+SquarePuzzle.h"

@implementation NSMutableArray (SquarePuzzle)

+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(int)width height:(int)height
{
#ifdef OPTIMIZE_SQUARE_ROTATE
    width = MAX(width, height);
    height = width;
#endif
    
    NSMutableArray <NSMutableArray <SquareUnit *> *> *squareArr = [NSMutableArray arrayWithCapacity:height];
    for (int i=0; i<height; i++) {
        NSMutableArray <SquareUnit *>*rowArr = [NSMutableArray arrayWithCapacity:width];
        for (int i=0; i<width; i++) {
            [rowArr addObject:[SquareUnit new]];
        }
        
        [squareArr addObject:rowArr];
    }
    
    return squareArr;
}

@end
