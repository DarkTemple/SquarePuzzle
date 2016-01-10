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

static inline BOOL addToHashTable(int *hashTable, int n, int x) {
    int j = 0;
    BOOL success = YES;
    for (; j<n; j++) {
        if (hashTable[j] == x || hashTable[j] == 0) {
            break;
        }
    }
    
    if (hashTable[j] == 0) {
        hashTable[j] = x;
    } else {
        success = NO;
    }
    
    return success;
}


@interface SquarePuzzleSolver : NSObject <SquareMatrixProtocol>

@property (nonatomic, strong) NSMutableArray <NSString *> *solutions;

- (instancetype)initWithBorderWidth:(int)width height:(int)height minBlockUnitCount:(int)minUnitCount;
- (void)addSquareUnit:(SquareBlock *)block;
- (BOOL)arrangeBlock:(SquareBlock *)block atX:(int)x Y:(int)y;
- (void)arrangeBlocks:(NSMutableArray <SquareBlock *> *)blocks;
- (void)solvePuzzle;
- (void)printAllSolutions;
- (NSArray <UIView *> *)generateSolutionGridViews;
- (UIView *)generateSolutionGridViewWithSolString:(NSString *)solStr;
@end
