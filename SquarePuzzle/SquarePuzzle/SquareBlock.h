//
//  SquareBlock.h
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSMutableArray+SquarePuzzle.h"
#import "BlockView.h"
#import "Global.h"

typedef NS_ENUM(NSInteger, SquareUnitState) {
    SquareUnitStateEmpty = 0,
    SquareUnitStateFull,
    SquareUnitStateVisited = -1,
};

typedef struct {
    int x;
    int y;
} SPPoint;

@interface SquareUnit : NSObject <NSCopying> {
@public
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

@interface SquareBlock : NSObject <SquareMatrixProtocol, NSCopying>

@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *shapeArr;
@property (nonatomic) SPPoint startPoint;
@property (nonatomic) SPPoint arrangePoint;

@property (nonatomic) NSInteger blockID;
@property (nonatomic, strong) UIColor *blockColor;

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr width:(int)width height:(int)height;
- (SquareBlock *)rotateClockwise;
- (void)rotateClockwiseInplace;

- (SquareBlock *)reverseBlock;
- (void)reverseBlockInplace;
- (NSInteger)block2HashCode;

- (BlockView *)generateBlockViewWithWidth:(CGFloat)width;

@end
