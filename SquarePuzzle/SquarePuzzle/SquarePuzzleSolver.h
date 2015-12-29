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

@interface SquareUnit : NSObject <NSCopying>
@property (nonatomic) SquareUnitState unitState;
@property (nonatomic, strong) NSString *blockID;
@property (nonatomic, strong) UIColor *blockColor;
- (void)reset;
@end

@protocol SquareMatrixProtocol <NSObject>
- (NSInteger)width;
- (NSInteger)height;
- (NSArray <NSArray <SquareUnit *> *> *)unitArr;
- (void)printSquare;
@end

@interface NSMutableArray (SquarePuzzle)
+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(NSInteger)width height:(NSInteger)height;
@end

@interface SquareBlock : NSObject <SquareMatrixProtocol>

@property (nonatomic, strong) NSString *blockID;
@property (nonatomic, strong) UIColor *blockColor;

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr;
//- (SquareBlock *)rotateClockwise;
- (void)rotateClockwiseInplace;

//- (SquareBlock *)reverseBlock;
- (void)reverseBlockInplace;
@end


@interface SquarePuzzleSolver : NSObject <SquareMatrixProtocol>

- (instancetype)initWithBorderWidth:(NSInteger)width height:(NSInteger)height minBlockUnitCount:(NSInteger)minUnitCount;
- (void)addSquareUnit:(SquareBlock *)block;
- (BOOL)arrangeBlock:(SquareBlock *)block atX:(NSInteger)x Y:(NSInteger)y;
- (void)arrangeBlocks:(NSMutableArray <SquareBlock *> *)blocks;
- (void)solvePuzzle;
- (void)printAllSolutions;
- (NSArray <UIView *> *)generateSolutionGridViews;

@end
