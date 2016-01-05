//
//  SquareBlock.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "SquareBlock.h"

static inline void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

@implementation SquareUnit

- (id)copyWithZone:(NSZone *)zone
{
    SquareUnit *copy = [[[self class] allocWithZone:zone] init];
    copy.unitState = self.unitState;
    copy.blockID = self.blockID;
    copy.blockColor = self.blockColor;
    return copy;
}

- (SquareUnitState)unitState
{
    return _unitState;
}

- (void)setUnitState:(SquareUnitState)unitState
{
    _unitState = unitState;
}

- (void)reset
{
    self.unitState = SquareUnitStateEmpty;
    self.blockID = 0;
    self.blockColor = nil;
}
@end


@interface SquareBlock ()
{
    int _width;
    int _height;
@public
    IMP rotateSquareIMP;
    SEL rotateSquareSEL;
}

@end


@implementation SquareBlock

- (NSInteger)block2HashCode
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
    NSInteger signature = 0;
    int width = self.width, height = self.height;
    SPPoint startPoint = self.startPoint;
    int n = (int)MAX(width, height);
    for (int i=(int)startPoint.y; i<startPoint.y+n; i++) {
        if (i < startPoint.y+height) {
            __unsafe_unretained NSArray <SquareUnit *> *tempArr = squareBoardArr[i];
            for (int j=(int)startPoint.x; j<startPoint.x+n; j++) {
                int x = 0;
                if (j < startPoint.x+width) {
                    x = ((tempArr[j].unitState == SquareUnitStateFull) ? 1 : 0);
                }
                
                signature = (signature << 1) + x;
            }
        }
    }
    
    return signature;
#else
    NSInteger signature = 0;
    int n = (int)MAX(self.width, self.height);
    for (int i=(int)self.startPoint.y; i<self.startPoint.y+n; i++) {
        if (i < self.startPoint.y+self.height) {
            for (int j=(int)self.startPoint.x; j<self.startPoint.x+n; j++) {
                int x = 0;
                if (j < self.startPoint.x+self.width) {
                    x = ((self.unitArr[i][j].unitState == SquareUnitStateFull) ? 1 : 0);
                }
                
                signature = (signature << 1) + x;
            }
        }
    }
    
    return signature;
#endif
}

- (int)width
{
#ifdef OPTIMIZE_WIDTH_HEIGHT_GETTER
    return _width;
#else
    return self.unitArr[0].count;
#endif
}

- (int)height
{
#ifdef OPTIMIZE_WIDTH_HEIGHT_GETTER
    return _height;
#else
    return self.unitArr.count;
#endif
}

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr width:(int)width height:(int)height
{
    if (self = [super init]) {
        _shapeArr = shapeArr;
        rotateSquareSEL = @selector(rotateClockwise);
        rotateSquareIMP = [self methodForSelector:rotateSquareSEL];
        
#ifdef OPTIMIZE_SQUARE_ROTATE
        _height = height;
        _width = width;
#else
        _height = shapeArr.count;
        _width = shapeArr[0].count;
#endif
        
        _startPoint.x = 0;
        _startPoint.y = 0;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSMutableArray <NSMutableArray <SquareUnit *> *> *shapeArr = [NSMutableArray squareArrayWithWidth:self.width height:self.height];
    SquareBlock *copy = [[[self class] allocWithZone:zone] initWithSquarShapeArr:shapeArr width:self.width height:self.height];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            shapeArr[i][j] = [self.unitArr[i][j] copy];
        }
    }
    
    copy.blockID = self.blockID;
    copy.blockColor = self.blockColor;
    return copy;
}

- (NSArray <NSArray <SquareUnit *> *> *)unitArr
{
    return self.shapeArr;
}

- (void)printSquare
{
    int n = (int)MAX(self.width, self.height);
    for (int i=0; i<n; i++) {
        for (int j=0; j<n; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateFull) {
                printf("%ld    ", self.blockID);
            } else {
                printf("%d    ", 0);
            }
            //            printf("%ld    ", self.unitArr[i][j].unitState);
        }
        
        printf("\n");
    }
    
    printf("%d\t%d", _startPoint.y, _startPoint.x);
    
    printf("\n");
}

- (SquareBlock *)rotateClockwise
{
//    rotateSquareCounter++;
    NSMutableArray *squareArr = [NSMutableArray squareArrayWithWidth:self.height height:self.width];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            squareArr[j][self.height-i-1] = [self.unitArr[i][j] copy];
        }
    }
    
    SquareBlock *rotate = [[SquareBlock alloc] initWithSquarShapeArr:squareArr width:self.height height:self.width];
    rotate.blockID = self.blockID;
    rotate.blockColor = self.blockColor;
    return rotate;
}

- (void)rotateClockwiseInplace
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *blockArr = self.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *blockArr = self.unitArr;
#endif
    
    _startPoint.x = _startPoint.y = INT_MAX;
    int n = (int)MAX(self.width, self.height);
    swap(&_width, &_height);
    
    for (int i=0; i<n/2; i++) {
        for (int j=i; j<n-i-1; j++) {
            SquareUnitState first = blockArr[i][j].unitState;
            int cur_i = i, cur_j = j;
            int next_i = n-cur_j-1, next_j = i;
            while (!(next_i == i && next_j == j)) {
                SquareUnitState nextState = blockArr[next_i][next_j].unitState;
                blockArr[cur_i][cur_j].unitState = nextState;
                if (nextState == SquareUnitStateFull) {
                    _startPoint.y = MIN(_startPoint.y, cur_i);
                    _startPoint.x = MIN(_startPoint.x, cur_j);
                }
                
                cur_i = next_i, cur_j = next_j;
                next_i = n-cur_j-1, next_j = cur_i;
            }
            
            blockArr[cur_i][cur_j].unitState = first;
            if (first != SquareUnitStateEmpty) {
                _startPoint.y = MIN(_startPoint.y, cur_i);
                _startPoint.x = MIN(_startPoint.x, cur_j);
            }
        }
    }
    
    if (n % 2) {
        if (blockArr[n/2][n/2].unitState != SquareUnitStateEmpty) {
            _startPoint.y = MIN(_startPoint.y, n/2);
            _startPoint.x = MIN(_startPoint.x, n/2);
        }
    }
}

- (SquareBlock *)reverseBlock
{
    NSMutableArray *squareArr = [NSMutableArray squareArrayWithWidth:self.width height:self.height];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            squareArr[i][self.width-j-1] = [self.unitArr[i][j] copy];
        }
    }
    
    SquareBlock *reverse = [[SquareBlock alloc] initWithSquarShapeArr:squareArr width:self.height height:self.width];
    reverse.blockID = self.blockID;
    reverse.blockColor = self.blockColor;
    return reverse;
}

- (void)reverseBlockInplace
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *blockArr = self.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *blockArr = self.unitArr;
#endif
    
    _startPoint.x = _startPoint.y = INT_MAX;
    int n = (int)MAX(self.width, self.height);
    for (int i=0; i<n; i++) {
        for (int j=0; j<n/2; j++) {
            SquareUnitState stateA = blockArr[i][j].unitState;
            SquareUnitState stateB = blockArr[i][n-j-1].unitState;
            blockArr[i][j].unitState = stateB;
            blockArr[i][n-j-1].unitState = stateA;
            if (stateA == SquareUnitStateFull) {
                _startPoint.y = MIN(_startPoint.y, i);
                _startPoint.x = MIN(_startPoint.x, n-j-1);
            }
            
            if (stateB == SquareUnitStateFull) {
                _startPoint.y = MIN(_startPoint.y, i);
                _startPoint.x = MIN(_startPoint.x, j);
            }
        }
    }
    
    if (n % 2) {
        for (int i=0; i<n; i++) {
            SquareUnitState state = blockArr[i][n/2].unitState;
            if (state == SquareUnitStateFull) {
                _startPoint.y = MIN(_startPoint.y, i);
                _startPoint.x = MIN(_startPoint.x, n/2);
            }
        }
    }
}

- (BlockView *)generateBlockViewWithWidth:(CGFloat)width
{
    return [[BlockView alloc] initWithSquare:self gridWidth:width];
}

@end
