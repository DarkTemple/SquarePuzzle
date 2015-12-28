//
//  SquarePuzzleSolver.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#define START { clock_t start, end; start = clock();
#define END end = clock(); \
printf("Cost:%f\n", (double)(end - start) / CLOCKS_PER_SEC * 1000);}


#define OPTIMIZE_BLOCK_TRANSFORM
#define OPTIMIZE_MSGSEND
#define OPTIMIZE_WIDTH_HEIGHT_GETTER

#import "SquarePuzzleSolver.h"
#import <objc/runtime.h>

static NSInteger arrangeBlksCounter = 0;
static NSInteger arrangeXYCounter = 0;
static NSInteger dfsMinAreaBlkCounter = 0;
static NSInteger dfsMinAreaXYCounter = 0;
static NSInteger rotateSquareCounter = 0;

@implementation SquareUnit

- (void)reset
{
    self.unitState = SquareUnitStateEmpty;
    self.blockID = nil;
    self.blockColor = nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    SquareUnit *copy = [[[self class] allocWithZone:zone] init];
    copy.unitState = self.unitState;
    copy.blockID = self.blockID;
    copy.blockColor = self.blockColor;
    return copy;
}

@end


@implementation NSMutableArray (SquarePuzzle)

+ (NSMutableArray <NSMutableArray <SquareUnit *> *> *)squareArrayWithWidth:(NSInteger)width height:(NSInteger)height
{
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

@interface SquareBlock ()
{
    NSInteger _width;
    NSInteger _height;
@public
    IMP rotateSquareIMP;
    SEL rotateSquareSEL;
}

@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *shapeArr;
@end


@implementation SquareBlock

- (id)copyWithZone:(NSZone *)zone
{
    SquareBlock *copy = [[[self class] allocWithZone:zone] initWithSquarShapeArr:[NSMutableArray squareArrayWithWidth:self.width height:self.height]];
    copy.blockID = self.blockID;
    copy.blockColor = self.blockColor;
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            copy.unitArr[i][j].unitState = self.unitArr[i][j].unitState;
            copy.unitArr[i][j].blockID = self.unitArr[i][j].blockID;
            copy.unitArr[i][j].blockColor = self.unitArr[i][j].blockColor;
        }
    }

    return copy;
}

- (BOOL)isEqual:(id)object
{
    SquareBlock *other = (SquareBlock *)object;
    if (self.width == other.width && self.height == other.height) {
        for (int i=0; i<self.height; i++) {
            for (int j=0; j<self.width; j++) {
                if (self.unitArr[i][j].unitState != other.unitArr[i][j].unitState) {
                    return NO;
                }
            }
        }
    } else {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.blockID integerValue];
}

- (NSInteger)width
{
#ifdef OPTIMIZE_WIDTH_HEIGHT_GETTER
    return _width;
#else
    return self.unitArr[0].count;
#endif
}

- (NSInteger)height
{
#ifdef OPTIMIZE_WIDTH_HEIGHT_GETTER
    return _height;
#else
    return self.unitArr.count;
#endif
}

- (instancetype)initWithSquarShapeArr:(NSArray <NSArray <SquareUnit *> *> *)shapeArr
{
    if (self = [super init]) {
        _shapeArr = shapeArr;
        _height = shapeArr.count;
        _width = shapeArr[0].count;
        rotateSquareSEL = @selector(rotateClockwise);
        rotateSquareIMP = [self methodForSelector:rotateSquareSEL];
    }
    
    return self;
};

- (NSArray <NSArray <SquareUnit *> *> *)unitArr
{
    return self.shapeArr;
}

- (void)printSquare
{
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateFull) {
                printf("%ld    ", [self.blockID integerValue]);
            } else {
                printf("%ld    ", 0);
            }
        }
        
        printf("\n");
    }
    
    printf("\n");
}

- (SquareBlock *)rotateClockwise
{
    rotateSquareCounter++;
    NSMutableArray *squareArr = [NSMutableArray squareArrayWithWidth:self.height height:self.width];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            squareArr[j][self.height-i-1] = [self.unitArr[i][j] copy];
        }
    }
    
    SquareBlock *rotate = [[SquareBlock alloc] initWithSquarShapeArr:squareArr];
    rotate.blockID = self.blockID;
    rotate.blockColor = self.blockColor;
    return rotate;
}

- (SquareBlock *)reverseBlock
{
    NSMutableArray *squareArr = [NSMutableArray squareArrayWithWidth:self.width height:self.height];
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            squareArr[i][self.width-j-1] = [self.unitArr[i][j] copy];
        }
    }
    
    SquareBlock *reverse = [[SquareBlock alloc] initWithSquarShapeArr:squareArr];
    reverse.blockID = self.blockID;
    reverse.blockColor = self.blockColor;
    return reverse;
}

@end
@interface SquarePuzzleSolver () {
    IMP arrangeBlksIMP;
    SEL arrangeBlksSEL;
    
    IMP arrangeXYIMP;
    SEL arrangeXYSEL;

    IMP dfsMinAreaBlkIMP;
    SEL dfsMinAreaBlkSEL;
    
    IMP dfsMinAreaXYIMP;
    SEL dfsMinAreaXYSEL;
    
    NSInteger _width;
    NSInteger _height;
}

@property (nonatomic, strong) NSArray <NSArray <SquareUnit *> *> *squareBoardArr;
@property (nonatomic, strong) NSMutableArray <SquareBlock *> *allBlocks;
@property (nonatomic, strong) NSMutableSet <NSString *> *solutions;
@property (nonatomic) NSInteger minUnitCount;
@end


@implementation SquarePuzzleSolver

- (instancetype)initWithBorderWidth:(NSInteger)width height:(NSInteger)height minBlockUnitCount:(NSInteger)minUnitCount
{
    if (self = [super init]) {
        _width = width;
        _height = height;
        _squareBoardArr = [NSMutableArray squareArrayWithWidth:width height:height];
        _allBlocks = [NSMutableArray array];
        _minUnitCount = minUnitCount;
        _solutions = [NSMutableSet set];
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

- (NSInteger)width
{
#ifdef OPTIMIZE_WIDTH_HEIGHT_GETTER
    return _width;
#else
    return self.unitArr[0].count;
#endif
}

- (NSInteger)height
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
                printf("%ld    ", [self.unitArr[i][j].blockID integerValue]);
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
            [solStr appendString:self.unitArr[i][j].blockID];
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
        [self.solutions addObject:[self blockArrangement2String]];
//        [self printSquare];
        return;
    }
    
//    [self printSquare];
    BOOL arrange = NO;
    SquareBlock *block = blocks[0];
    SquareBlock *origBlock = [block copy];
    [blocks removeObject:block];
    
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {

#ifdef OPTIMIZE_BLOCK_TRANSFORM
            NSMutableSet *blockSet = [NSMutableSet set];
#endif
            for (int r=0; r<8; r++) {
                if (r == 4) {
                    block = [block reverseBlock];
                }
                
                if (r != 0) {
                    
#ifdef OPTIMIZE_MSGSEND
                    block = ((id (*)(id obj, SEL sel, ...))block->rotateSquareIMP)(block, block->rotateSquareSEL);
#else
                    block = [block rotateClockwise];
#endif
                    
                }
#ifdef OPTIMIZE_BLOCK_TRANSFORM
                if ([blockSet containsObject:block]) {
                    continue;
                } else {
                    [blockSet addObject:block];
                }
#endif

                
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
                    
                    [self removeBlock:block];
//                    if (arrangeRest) {
                        // find one solution
//                        arrange = YES;
//                        goto OUT_HERE;
//                    }
                }
            }
        }
    }
    
    [blocks insertObject:origBlock atIndex:0];
    
//OUT_HERE:
//    if (!arrange) {
//        [blocks insertObject:[block rotateClockwise] atIndex:0];
//    }
//    
//    return arrange;
}

- (BOOL)arrangeBlock:(SquareBlock *)block atX:(NSInteger)x Y:(NSInteger)y
{
    arrangeXYCounter++;
    
    NSInteger borderWidth = self.width;
    NSInteger borderHeight = self.height;
    NSInteger blockWidth = block.width;
    NSInteger blockHeight = block.height;
    if (x+blockWidth > borderWidth || y+blockHeight>borderHeight) {
        return NO;
    }
    
    BOOL arrange = YES;
    for (int i=0; i<blockHeight; i++) {
        for (int j=0; j<blockWidth; j++) {
            if (block.unitArr[i][j].unitState == SquareUnitStateFull) {
                if (self.unitArr[i+y][j+x].unitState == SquareUnitStateEmpty) {
                    self.unitArr[i+y][j+x].unitState = SquareUnitStateFull;
                    self.unitArr[i+y][j+x].blockID = block.blockID;
                    self.unitArr[i+y][j+x].blockColor = block.blockColor;
                } else {
                    arrange = NO;
                    goto OUT_HERE;
                }
            }
        }
    }
    
OUT_HERE:
    if (arrange) {
        // check min connected area
#ifdef OPTIMIZE_MSGSEND
        arrange = ((BOOL (*)(id obj, SEL sel, ...))dfsMinAreaBlkIMP)(self, dfsMinAreaBlkSEL, self.minUnitCount);
#else
        arrange = [self DFSMinConnectedCountLimit:self.minUnitCount];
#endif
        [self clearVisitedFootprint];
    }
    
    if (!arrange) {
        [self removeBlock:block];
    }
    
    return arrange;
}

- (void)clearVisitedFootprint
{
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateVisited) {
                self.unitArr[i][j].unitState = SquareUnitStateEmpty;
            }
        }
    }
}

- (void)removeBlock:(SquareBlock *)block
{
    // remove
    for (int i=0; i<self.height; i++) {
        for (int j=0; j<self.width; j++) {
            if ([self.unitArr[i][j].blockID isEqualToString:block.blockID ]) {
                [self.unitArr[i][j] reset];
            }
        }
    }
}

- (BOOL)DFSMinConnectedCountLimit:(NSInteger)limit
{
    dfsMinAreaBlkCounter++;
    NSInteger minCount = INT_MAX;
    for (int i=0; i<self.height; i++) {
        for (int j=(int)0; j<self.width; j++) {
            if (self.unitArr[i][j].unitState == SquareUnitStateEmpty) {
                NSInteger connectedAreaCount = 0;
                
#ifdef OPTIMIZE_MSGSEND
                ((void (*)(id obj, SEL sel, ...))dfsMinAreaXYIMP)(self, dfsMinAreaXYSEL, i, j, &connectedAreaCount);
#else
                [self DFSConnectedAreaCountStartFromX:i Y:j count:&connectedAreaCount];
#endif
                
                
                minCount = MIN(minCount, connectedAreaCount);
                if (minCount < limit) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (void)DFSConnectedAreaCountStartFromX:(NSInteger)x Y:(NSInteger)y count:(NSInteger *)count
{
    dfsMinAreaXYCounter++;
    
    if ((x < 0 || x >= self.height) || (y < 0 || y >= self.width)) {
        return;
    }
    
    if (self.unitArr[x][y].unitState == SquareUnitStateEmpty) {
        (*count)++;
        self.unitArr[x][y].unitState = SquareUnitStateVisited;
        
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
    
#ifdef OPTIMIZE_MSGSEND
    ((void (*)(id obj, SEL sel, ...))arrangeBlksIMP)(self, arrangeBlksSEL, self.allBlocks);
#else
    [self arrangeBlocks:self.allBlocks];
#endif
    
    NSLog(@"arrangeBlksCounter : %ld", (long)arrangeBlksCounter);
    NSLog(@"arrangeXYCounter : %ld", (long)arrangeXYCounter);
    NSLog(@"dfsMinAreaBlkCounter : %ld", (long)dfsMinAreaBlkCounter);
    NSLog(@"dfsMinAreaCounter : %ld", (long)dfsMinAreaXYCounter);
    NSLog(@"rotateSquareCounter : %ld", (long)rotateSquareCounter);
}

- (void)printAllSolutions
{
    [self.solutions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"%@", obj);
    }];
}

- (SquareBlock *)searchBlockWithBlockID:(NSString *)blockID
{
    __block SquareBlock *ret = nil;
    [self.allBlocks enumerateObjectsUsingBlock:^(SquareBlock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.blockID isEqualToString:blockID]) {
            ret = obj;
            *stop = YES;
        }
    }];
    
    return ret;
}

- (NSArray <UIView *> *)generateSolutionGridViews
{
    NSMutableArray <UIView *> *allSolViews = [NSMutableArray array];
    [self.solutions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
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
        SquareBlock *block = [self searchBlockWithBlockID:blockID];
        GridUnitView *grid = [[GridUnitView alloc] initWithColor:block.blockColor];
        NSInteger row = idx / self.width;
        NSInteger col = idx % self.width;
        grid.frame = CGRectMake(col*gridWidth, row*gridWidth, gridWidth, gridWidth);
        [borderView addSubview:grid];
    }];
    
    return borderView;
}

@end
