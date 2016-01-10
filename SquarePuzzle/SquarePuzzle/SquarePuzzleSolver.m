
//  SquarePuzzleSolver.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#define START { clock_t start, end; start = clock();
#define END end = clock(); \
printf("Cost:%f\n", (double)(end - start) / CLOCKS_PER_SEC * 1000);}


#import "SquarePuzzleSolver.h"
#import <objc/runtime.h>

static const int kMaxBoardWidth = 15;

static NSInteger arrangeBlksCounter = 0;
static NSInteger arrangeXYCounter = 0;
static NSInteger dfsMinAreaBlkCounter = 0;
static NSInteger dfsMinAreaXYCounter = 0;
static NSInteger rotateSquareCounter = 0;

static NSInteger hashCounter = 0;
static NSInteger equalCounter = 0;

static inline int minInRange(int *arr, int start, int len) {
    int min = INT_MAX;
    for (int i=start; i<start+len; i++) {
        min = MIN(min, arr[i]);
    }
    
    return min;
}

static inline int maxInRange(int *arr, int start, int len) {
    int max = INT_MIN;
    for (int i=start; i<start+len; i++) {
        max = MAX(max, arr[i]);
    }
    
    return max;
}

@interface SquarePuzzleSolver () {
    IMP arrangeBlksIMP;
    SEL arrangeBlksSEL;
    
    IMP arrangeXYIMP;
    SEL arrangeXYSEL;

    IMP dfsMinAreaBlkIMP;
    SEL dfsMinAreaBlkSEL;
    
    IMP dfsMinAreaXYIMP;
    SEL dfsMinAreaXYSEL;
    
    int _width;
    int _height;
    
    int _minValidXTable[kMaxBoardWidth];
    int _maxValidXTable[kMaxBoardWidth];
}

@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *squareBoardArr;
@property (nonatomic, strong) NSMutableArray <SquareBlock *> *allBlocks;
@property (nonatomic) int minUnitCount;
@end


@implementation SquarePuzzleSolver

- (instancetype)initWithBorderWidth:(int)width height:(int)height minBlockUnitCount:(int)minUnitCount
{
    if (self = [super init]) {
        _width = width;
        _height = height;
        memset(_minValidXTable, 0, sizeof(int)*kMaxBoardWidth);
        for (int i=0; i<kMaxBoardWidth; i++) {
            _maxValidXTable[i]= (int)width-1;
        }
        
        NSMutableArray <NSMutableArray <SquareUnit *> *> *squareArr = [NSMutableArray arrayWithCapacity:height];
        for (int i=0; i<height; i++) {
            NSMutableArray <SquareUnit *>*rowArr = [NSMutableArray arrayWithCapacity:width];
            for (int i=0; i<width; i++) {
                [rowArr addObject:[SquareUnit new]];
            }
            
            [squareArr addObject:rowArr];
        }
        
        _squareBoardArr = squareArr;
        _allBlocks = [NSMutableArray array];
        _minUnitCount = minUnitCount;
        _solutions = [NSMutableArray array];
        arrangeBlksIMP = [self methodForSelector:@selector(arrangeBlocks:)];
        arrangeBlksSEL = @selector(arrangeBlocks:);
        arrangeXYIMP = [self methodForSelector:@selector(arrangeBlock:atX:Y:)];
        arrangeXYSEL = @selector(arrangeBlock:atX:Y:);
        dfsMinAreaBlkIMP = [self methodForSelector:@selector(DFSMinConnectedCountLimit:)];
        dfsMinAreaXYSEL = @selector(DFSMinConnectedCountLimit:);
        dfsMinAreaXYIMP = [self methodForSelector:@selector(DFSConnectedAreaCountStartFromX:Y:count:)];
        dfsMinAreaXYSEL = @selector(DFSConnectedAreaCountStartFromX:Y:count:);
    }
    
    return self;
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

- (NSArray <NSArray <SquareUnit *> *> *)unitArr
{
    return self.squareBoardArr;
}

- (void)printSquare
{
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateFull) {
                printf("%ld    ", self.unitArr[i][j].blockID);
            } else {
                printf("%d    ", 0);
            }
        }
        
        printf("\n");
    }
    
    printf("\n");
}

- (NSString *)blockArrangement2String
{
    NSMutableString *solStr = [NSMutableString string];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            [solStr appendString:[NSString stringWithFormat:@"%ld", self.unitArr[i][j].blockID]];
            if (!(i == self.height-1 && j == self.width-1)) {
                [solStr appendString:@","];
            }
        }
    }
    
    return [NSString stringWithString:solStr];
}

- (void)addSquareUnit:(SquareBlock *)block
{
    [self.allBlocks addObject:block];
}

- (void)arrangeBlocks:(NSMutableArray <SquareBlock *> *)blocks
{
    arrangeBlksCounter++;
    
    if (!blocks.count) {
        NSString *solString = [self blockArrangement2String];
        [self.solutions addObject:solString];
//        [self printSquare];
        return;
    }
    
//    BOOL arrange = NO;
    SquareBlock *block = blocks[0];
    [blocks removeObject:block];
    
#ifdef OPTIMIZE_BLOCK_TRANSFORM_DUP
    int hashTable[8] = {0};
#endif
    for (int r=0; r<8; r++) {
        if (r == 4) {
#ifdef OPTIMIZE_SQUARE_ROTATE
            [block reverseBlockInplace];
#else
            block = [block reverseBlock];
#endif
        }
        
        if (r != 0) {
#ifdef OPTIMIZE_SQUARE_ROTATE
            [block rotateClockwiseInplace];
#else
            block = [block rotateClockwise];
#endif
        }
      
#ifdef OPTIMIZE_BLOCK_TRANSFORM_DUP
        int signature = (int)[block block2HashCode];
        if (!(addToHashTable(hashTable, 8, signature))) {
            continue;
        }
#endif
        
        int borderWidth = self.width;
        int borderHeight = self.height;
        int blockWidth = block.width;
        int blockHeight = block.height;
        
//        for (int i=0; i<=borderHeight-blockHeight; i++) {
        for (int i=0; i<=borderHeight-blockHeight; i++) {
#ifdef OPTIMIZE_ARRANGE_SEARCH_RANGE
            int j = minInRange(_minValidXTable, i, (int)blockHeight);
            int jEnd = maxInRange(_maxValidXTable, i, (int)blockHeight)-(int)blockWidth+1;
#else
            int j = 0;
            int jEnd = borderWidth-blockWidth;
#endif
            for (; j<=jEnd; j++) {
#ifdef OPTIMIZE_MSGSEND
                BOOL arrangeOne = ((BOOL (*)(id sender, SEL sel, ...))arrangeXYIMP)(self, arrangeXYSEL, block, j, i);
#else
                BOOL arrangeOne = [self arrangeBlock:block atX:j Y:i];
#endif
                
                if (arrangeOne) {
#ifdef OPTIMIZE_MSGSEND
                    ((void (*)(id obj, SEL sel, ...))arrangeBlksIMP)(self, arrangeBlksSEL, self.allBlocks);
#else
                    [self arrangeBlocks:self.allBlocks];
#endif
                    
#ifndef FIND_ALL_SOLUTIONS
                    if (self.solutions.count > 0) {
                        [blocks insertObject:block atIndex:0];
                        return;
                    }
#endif
                    
                    [self removeBlock:block];
                }
            }
        }
    }

    [blocks insertObject:block atIndex:0];
}

- (BOOL)arrangeBlock:(SquareBlock *)block atX:(int)x Y:(int)y
{
    arrangeXYCounter++;
    
    int borderWidth = self.width;
    int borderHeight = self.height;
    int blockWidth = block.width;
    int blockHeight = block.height;
    
    BOOL arrange = YES;
    
#ifdef OPTIMIZE_SQUARE_ROTATE
    int startY = block.startPoint.y;
    int startX = block.startPoint.x;
#else
    int startY = 0;
    int startX = 0;
#endif
    
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *blockArr = block.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
    NSArray <NSArray <SquareUnit *> *> *blockArr = block.unitArr;
#endif
    
    BOOL arrangeUnit = NO;
    for (int i=0; i<blockHeight; i++) {
        for (int j=0; j<blockWidth; j++) {
            if (blockArr[i+startY][j+startX].unitState == SquareUnitStateFull) {
                if (squareBoardArr[i+y][j+x].unitState == SquareUnitStateEmpty) {
                    squareBoardArr[i+y][j+x].unitState = SquareUnitStateFull;
                    squareBoardArr[i+y][j+x].blockID = block.blockID;
                    squareBoardArr[i+y][j+x].blockColor = block.blockColor;
                    
                    if (_minValidXTable[i+y] == j+x) {
                        _minValidXTable[i+y] = (int)(j+x+1);
                    }
                    
                    if (_maxValidXTable[i+y] == j+x) {
                        _maxValidXTable[i+y] = (int)(j+x-1);
                    }
                    
                    arrangeUnit = YES;
                } else {
                    arrange = NO;
                    goto OUT_HERE;
                }
            }
        }
    }
    
OUT_HERE:
    {
        SPPoint point = {(int)x, (int)y};
        block.arrangePoint = point;
        
        if (arrange) {
            
#ifdef OPTIMIZE_ARRANGE_CONNECTED_DFS
    #ifdef OPTIMIZE_DFS_SEARCH_POINT
            arrange = [self DFSMinConnectedCountLimit:self.minUnitCount afterArrange:block];
    #else
            arrange = [self DFSMinConnectedCountLimit:self.minUnitCount];
    #endif
            [self clearVisitedFootprint];
#endif
        }
        
        if (!arrange && arrangeUnit) {
            [self removeBlock:block];
        } else {
            
        }
    }

    return arrange;
}

- (void)clearVisitedFootprint
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
    int height = self.height;
    int width = self.width;
    for (int i=0; i<height; i++) {
        __unsafe_unretained NSArray <SquareUnit *> *tempArr = squareBoardArr[i];
        for (int j=0; j<width; j++) {
            if (tempArr[j].unitState == SquareUnitStateVisited) {
                tempArr[j].unitState = SquareUnitStateEmpty;
            }
        }
    }
#else
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateVisited) {
                self.unitArr[i][j].unitState = SquareUnitStateEmpty;
            }
        }
    }
#endif
}

- (void)removeBlock:(SquareBlock *)block
{
    // remove block
    
#ifdef OPTIMIZE_BLOCK_REMOVE
    int startY = block.arrangePoint.y;
    int startX = block.arrangePoint.x;
    int width = (int)block.width;
    int height = (int)block.height;
#else
    int startY = 0;
    int startX = 0;
    int width = self.width;
    int height = self.height;
#endif
    
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
    NSInteger blockID = block.blockID;
    for (int i=startY; i<startY+height; i++) {
        __unsafe_unretained NSArray <SquareUnit *> *tempArr = squareBoardArr[i];
        for (int j=startX; j<startX+width; j++) {
            NSInteger tmpblockID = tempArr[j].blockID;
            if (tmpblockID == blockID) {
                [tempArr[j] reset];
                
    #ifdef OPTIMIZE_ARRANGE_SEARCH_RANGE
                if (_minValidXTable[i] > j) {
                    _minValidXTable[i] = j;
                }
                
                if (_maxValidXTable[i] < j) {
                    _maxValidXTable[i] = j;
                }
    #endif
            }
        }
    }
#else
    NSInteger blockID = block.blockID;
    for (int i=startY; i<startY+height; i++) {
        for (int j=startX; j<startX+width; j++) {
            NSInteger tmpblockID = self.unitArr[i][j].blockID;
            if (tmpblockID == blockID) {
                [self.unitArr[i][j] reset];
                
#ifdef OPTIMIZE_ARRANGE_SEARCH_RANGE
                if (_minValidXTable[i] > j) {
                    _minValidXTable[i] = j;
                }
                
                if (_maxValidXTable[i] < j) {
                    _maxValidXTable[i] = j;
                }
#endif
            }
        }
    }
#endif
}

- (BOOL)DFSMinConnectedCountLimit:(int)limit
{
    
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#endif
    
    dfsMinAreaBlkCounter++;
    for (int i=0; i<self.height; i++) {
        for (int j=(int)0; j<self.width; j++) {
            if (squareBoardArr[i][j].unitState == SquareUnitStateEmpty) {
                int connectedAreaCount = 0;
                
#ifdef OPTIMIZE_MSGSEND
                ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, i, j, &connectedAreaCount);
#else
                [self DFSConnectedAreaCountStartFromX:i Y:j count:&connectedAreaCount];
#endif
                if (connectedAreaCount < limit) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)DFSMinConnectedCountLimit:(int)limit afterArrange:(SquareBlock *)block
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#endif
    
    SPPoint point = block.arrangePoint;
    int width = block.width;
    int height = block.height;
    
    int startY = MAX(0, point.y-1), startX = MAX(0, point.x-1);
    int endY = MIN(point.y+height+1, self.height), endX = MIN(point.x+width+1, self.width);
    
    for (int i=startY; i<endY; i++) {
        for (int j=startX; j<endX; j++) {
            if (squareBoardArr[i][j].unitState == SquareUnitStateEmpty) {
                int connectedAreaCount = 0;
#ifdef OPTIMIZE_MSGSEND
                ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, i, j, &connectedAreaCount);
#else
                [self DFSConnectedAreaCountStartFromX:i Y:j count:&connectedAreaCount];
#endif
                if (connectedAreaCount < limit) {
                    return NO;
                }
            }

        }
    }
    
    return YES;
}

- (void)DFSConnectedAreaCountStartFromX:(int)x Y:(int)y count:(int *)count
{
#ifdef OPTIMEZE_ENUMETATE_ARC
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#else
    NSArray <NSArray <SquareUnit *> *> *squareBoardArr = self.unitArr;
#endif
    
    dfsMinAreaXYCounter++;
    
    if ((x < 0 || x >= self.height) || (y < 0 || y >= self.width)) {
        return;
    }
    
    if (squareBoardArr[x][y].unitState == SquareUnitStateEmpty) {
        (*count)++;
        squareBoardArr[x][y].unitState = SquareUnitStateVisited;
        
#ifdef OPTIMIZE_MSGSEND
        ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, x+1, y, count);
        ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, x, y+1, count);
        ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, x-1, y, count);
        ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, x, y-1, count);
#else
        [self DFSConnectedAreaCountStartFromX:x+1 Y:y count:count];
        [self DFSConnectedAreaCountStartFromX:x Y:y+1 count:count];
        [self DFSConnectedAreaCountStartFromX:x-1 Y:y count:count];
        [self DFSConnectedAreaCountStartFromX:x Y:y-1 count:count];
#endif
    }
}

- (void)solvePuzzle
{
    arrangeXYCounter = 0;
    arrangeBlksCounter = 0;
    dfsMinAreaBlkCounter = 0;
    dfsMinAreaXYCounter = 0;
    rotateSquareCounter = 0;
    
    hashCounter = 0;
    equalCounter = 0;
    
#ifdef OPTIMIZE_MSGSEND
    ((void (*)(id obj, SEL sel, ...))arrangeBlksIMP)(self, arrangeBlksSEL, self.allBlocks);
#else
    [self arrangeBlocks:self.allBlocks];
#endif
    
    NSLog(@"arrangeBlksCounter : %ld", (long)arrangeBlksCounter);
    NSLog(@"arrangeXYCounter : %ld", (long)arrangeXYCounter);
    NSLog(@"dfsMinAreaBlkCounter : %ld", (long)dfsMinAreaBlkCounter);
    NSLog(@"dfsMinAreaXYCounter : %ld", (long)dfsMinAreaXYCounter);
    NSLog(@"rotateSquareCounter : %ld", (long)rotateSquareCounter);
    
    NSLog(@"hashCounter : %ld", (long)hashCounter);
    NSLog(@"equalCounter : %ld", (long)equalCounter);
}

- (void)printAllSolutions
{
    [self.solutions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%@", obj);
    }];
}

- (SquareBlock *)searchBlockWithBlockID:(NSInteger)blockID
{
    __block SquareBlock *ret = nil;
    [self.allBlocks enumerateObjectsUsingBlock:^(SquareBlock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.blockID == blockID) {
            ret = obj;
            *stop = YES;
        }
    }];
    
    return ret;
}

- (NSArray <UIView *> *)generateSolutionGridViews
{
    NSMutableArray <UIView *> *allSolViews = [NSMutableArray array];
    [self.solutions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [allSolViews addObject:[self generateSolutionGridViewWithSolString:obj]];
    }];
    
    return allSolViews;
}

- (UIView *)generateSolutionGridViewWithSolString:(NSString *)solStr
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat gridWidth = MIN((screenWidth - 60.f)/self.width, (screenHeight - 60.f)/self.height);
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, gridWidth*self.width, gridWidth*self.height)];
    
    [[solStr componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *blockID = obj;
        SquareBlock *block = [self searchBlockWithBlockID:[blockID integerValue]];
        GridUnitView *grid = [[GridUnitView alloc] initWithColor:block.blockColor];
        int row = (int)idx / self.width;
        int col = (int)idx % self.width;
        grid.frame = CGRectMake(col*gridWidth, row*gridWidth, gridWidth, gridWidth);
        [borderView addSubview:grid];
    }];
    
    return borderView;
}

@end
