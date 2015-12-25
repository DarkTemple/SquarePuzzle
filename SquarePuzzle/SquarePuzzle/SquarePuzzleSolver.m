//
//  SquarePuzzleSolver.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "SquarePuzzleSolver.h"
#import <UIKit/UIKit.h>


@implementation SquareUnit
@end


@implementation NSMutableArray (SquarePuzzle)

+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(NSInteger)width height:(NSInteger)height
{
    NSMutableArray <NSMutableArray <SquareUnit *> *> *squareArr = [NSMutableArray arrayWithCapacity:width];
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

@interface SquareBlock ()

@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *shapeArr;
@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@property (nonatomic, strong) NSString *blockID;
@property (nonatomic, strong) UIColor *blockColor;

@end


@implementation SquareBlock

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr
{
    if (self = [super init]) {
        _shapeArr = shapeArr;
    }
    
    return self;
};

- (NSInteger)width
{
    return self.shapeArr[0].count;
}

- (NSInteger)height
{
    return self.shapeArr.count;
}

- (SquareBlock *)rotateClockwise
{
    NSMutableArray *squareArr = [NSMutableArray squareArrayWithWidth:self.height height:self.width];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            squareArr[j][self.height-i-1] = self.shapeArr[i][j];
        }
    }
    
    return [[SquareBlock alloc] initWithSquarShapeArr:squareArr];
}

- (NSInteger)DFSMinConnectedCountStartFrom:(NSInteger)start
{
    NSInteger minCount = INT_MAX;
    for (int i=0; i<self.height; i++) {
        for (int j=(int)start; j<self.width; j++) {
            if (self.shapeArr[i][j].unitState == SquareUnitStateEmpty) {
                NSInteger connectedAreaCount = 0;
                [self DFSConnectedAreaCountStartFromX:i Y:j count:&connectedAreaCount];
                minCount = MIN(minCount, connectedAreaCount);
            }
        }
    }
    
    return minCount;
}

- (void)DFSConnectedAreaCountStartFromX:(NSInteger)x Y:(NSInteger)y count:(NSInteger *)count
{
    if ((x < 0 || x >= self.height) || (y < 0 || y >= self.width)) {
        return;
    }
    
    if (self.shapeArr[x][y].unitState == SquareUnitStateEmpty) {
        (*count)++;
        self.shapeArr[x][y].unitState = SquareUnitStateVisited;
        [self DFSConnectedAreaCountStartFromX:x+1 Y:y count:count];
        [self DFSConnectedAreaCountStartFromX:x Y:y+1 count:count];
        [self DFSConnectedAreaCountStartFromX:x-1 Y:y count:count];
        [self DFSConnectedAreaCountStartFromX:x Y:y-1 count:count];
    }
}

- (void)printSquare
{
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            printf("%ld    ", [self.shapeArr[i][j] unitState]);
        }
        
        printf("\n");
    }
}

@end


@interface SquarePuzzleSolver ()
@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *squareBoardArr;
@property (nonatomic, strong) NSMutableArray <SquareBlock *> *allBlocks;
@property (nonatomic, readonly) NSInteger width;
@property (nonatomic, readonly) NSInteger height;
@end


@implementation SquarePuzzleSolver

- (instancetype)initWithBorderWidth:(NSInteger)width height:(NSInteger)height
{
    if (self = [super init]) {
        _squareBoardArr = [NSMutableArray squareArrayWithWidth:width height:height];
        _allBlocks = [NSMutableArray array];
    }
    
    return self;
}

- (NSInteger)width
{
    return self.squareBoardArr[0].count;
}

- (NSInteger)height
{
    return self.squareBoardArr.count;
}

- (void)addSquareUnit:(SquareBlock *)block
{
    [self.allBlocks addObject:block];
}

- (BOOL)arrangeBlock:(SquareBlock *)block
{
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if (self.squareBoardArr[i][j].unitState == SquareUnitStateEmpty) {
                [self arrangeBlock:block atX:j Y:i];
            }
        }
    }
    // 从左到右从上到下找一个最近点放置
    
    // 如果不行，旋转重试
    
    // 还是不行，返回NO
    return YES;
}

- (BOOL)arrangeBlock:(SquareBlock *)block atX:(NSInteger)x Y:(NSInteger)y
{
    return NO;
}

- (void)solvePuzzle
{
    
}

@end
