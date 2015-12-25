//
//  SquarePuzzleSolver.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SquareUnitState) {
    SquareUnitStateEmpty = 0,
    SquareUnitStateFull,
    SquareUnitStateVisited = -1,
};

@interface SquareUnit : NSObject
@property (nonatomic) SquareUnitState unitState;
@property (nonatomic, strong) NSString *blockID;
@property (nonatomic, strong) NSString *blockColor;
@end

@interface NSMutableArray (SquarePuzzle)
+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(NSInteger)width height:(NSInteger)height;
@end

@interface SquareBlock : NSObject

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr;
- (SquareBlock *)rotateClockwise;
- (NSInteger)DFSMinConnectedCountStartFrom:(NSInteger)start;

- (void)printSquare;


@end


@interface SquarePuzzleSolver : NSObject

- (instancetype)initWithBorderWidth:(NSInteger)width height:(NSInteger)height;
- (void)addSquareUnit:(SquareBlock *)block;
- (void)solvePuzzle;

@end
