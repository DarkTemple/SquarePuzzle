//
//  SquarePuzzleSolver.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SquareBlock.h"
#import "GridUnitView.h"


@interface SquarePuzzleSolver : NSObject <SquareMatrixProtocol>

- (instancetype)initWithBorderWidth:(int)width height:(int)height minBlockUnitCount:(int)minUnitCount;
- (void)addSquareUnit:(SquareBlock *)block;
- (BOOL)arrangeBlock:(SquareBlock *)block atX:(int)x Y:(int)y;
- (void)arrangeBlocks:(NSMutableArray <SquareBlock *> *)blocks;
- (void)solvePuzzle;
- (void)printAllSolutions;
- (NSArray <UIView *> *)generateSolutionGridViews;

@end
