//
//  SquarePuzzleSolver.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GridUnitView.h"

typedef NS_ENUM(NSInteger, SquareUnitState) {
    SquareUnitStateEmpty = 0,
    SquareUnitStateFull,
    SquareUnitStateVisited = -1,
};

typedef struct {
    int x;
    int y;
} SPPoint;

@interface SquareUnit : NSObject {
    SquareUnitState _unitState;
}

@property (nonatomic) SquareUnitState unitState;
@property (nonatomic) NSInteger blockID;
@property (nonatomic, strong) UIColor *blockColor;
- (void)reset;
@end

@protocol SquareMatrixProtocol <NSObject>
- (int)width;
- (int)height;
- (NSArray <NSArray <SquareUnit *> *> *)unitArr;
- (void)printSquare;
@end

@interface NSMutableArray (SquarePuzzle)
+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(int)width height:(int)height;
@end

@interface SquareBlock : NSObject <SquareMatrixProtocol>

@property (nonatomic) NSInteger blockID;
@property (nonatomic, strong) UIColor *blockColor;

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr width:(int)width height:(int)height;
- (SquareBlock *)rotateClockwise;
- (void)rotateClockwiseInplace;

- (SquareBlock *)reverseBlock;
- (void)reverseBlockInplace;
@end


@interface SquarePuzzleSolver : NSObject <SquareMatrixProtocol>

- (instancetype)initWithBorderWidth:(int)width height:(int)height minBlockUnitCount:(int)minUnitCount;
- (void)addSquareUnit:(SquareBlock *)block;
- (BOOL)arrangeBlock:(SquareBlock *)block atX:(int)x Y:(int)y;
- (void)arrangeBlocks:(NSMutableArray <SquareBlock *> *)blocks;
- (void)solvePuzzle;
- (void)printAllSolutions;
- (NSArray <UIView *> *)generateSolutionGridViews;

@end
