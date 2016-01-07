//
//  BlockView.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "BlockView.h"
#import "SquareBlock.h"
#import "Global.h"

static const NSInteger kGridLineTag = 31415;

@interface BlockView ()
@property (nonatomic, strong) SquareBlock *block;
@property (nonatomic) CGFloat gridWidth;
@end

@implementation BlockView

- (instancetype)initWithSquare:(SquareBlock *)block gridWidth:(CGFloat)gridWidth
{
    _block = block;
    _gridWidth = gridWidth;
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        [self layoutSubviews];
        
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveBlock:)];
        [self addGestureRecognizer:panGR];
        
        UITapGestureRecognizer *tapGR1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlock1:)];
        tapGR1.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGR1];
        
        UITapGestureRecognizer *tapGR2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBlock2:)];
        tapGR2.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGR2];
        
        [tapGR1 requireGestureRecognizerToFail:tapGR2];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    int width = self.block.width;
    int height = self.block.height;
    UIColor *blockColor = self.block.blockColor;
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), width*self.gridWidth, height*self.gridWidth);
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    int startY = self.block.startPoint.y;
    int startX = self.block.startPoint.x;
    
    for (int i=startY; i<startY+height; i++) {
        for (int j=startX; j<startX+width; j++) {
            if (self.block.unitArr[i][j].unitState == SquareUnitStateFull) {
                GridUnitView *grid = [[GridUnitView alloc] initWithColor:blockColor];
                grid.frame = CGRectMake((j-startX)*self.gridWidth, (i-startY)*self.gridWidth, self.gridWidth, self.gridWidth);
                grid.userInteractionEnabled = NO;
                [self addSubview:grid];
            }
        }
    }
    
    // add x-y line
    for (int i=startY; i<height+1; i++) {
        UIView *xLine = [[UIView alloc] initWithFrame:CGRectMake(0, i*_gridWidth, _gridWidth*width, kLineWidth)];
        xLine.tag = kGridLineTag;
        xLine.backgroundColor = [UIColor blackColor];
        [self addSubview:xLine];
        xLine.alpha = 0;
    }
    
    for (int j=startX; j<width+1; j++) {
        UIView *yLine = [[UIView alloc] initWithFrame:CGRectMake(j*_gridWidth, 0, kLineWidth, _gridWidth*height)];
        yLine.tag = kGridLineTag;
        yLine.backgroundColor = [UIColor blackColor];
        [self addSubview:yLine];
        yLine.alpha = 0;
    }
}

- (void)moveBlock:(UIPanGestureRecognizer *)panGR
{
    CGPoint translation = [panGR translationInView:self];
    panGR.view.center = CGPointMake(panGR.view.center.x + translation.x,
                                         panGR.view.center.y + translation.y);
    [panGR setTranslation:CGPointZero inView:self];
    if (panGR.state == UIGestureRecognizerStateChanged) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == kGridLineTag) {
                obj.alpha = 1.f;
            }
        }];
        
        self.alpha = .3f;
    } else {
        self.alpha = 1.f;
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == kGridLineTag) {
                obj.alpha = 0.f;
            }
        }];
    }
    
    if (panGR.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.startPoint.x + roundf(((CGRectGetMinX(self.frame) - self.startPoint.x) / self.gridWidth)) * self.gridWidth;
        CGFloat y = self.startPoint.y + roundf(((CGRectGetMinY(self.frame) - self.startPoint.y) / self.gridWidth)) * self.gridWidth;
        self.frame = CGRectMake(x, y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
}

- (void)tapBlock1:(UITapGestureRecognizer *)tapGR
{
    NSLog(@"Roatate clockwise!");
#ifdef OPTIMIZE_SQUARE_ROTATE
    [self.block rotateClockwiseInplace];
#else
    self.block = [self.block rotateClockwise];
#endif
    
    [self layoutSubviews];
}

- (void)tapBlock2:(UITapGestureRecognizer *)tapGR
{
    NSLog(@"Reverse clockwise!");
#ifdef OPTIMIZE_SQUARE_ROTATE
    [self.block reverseBlockInplace];
#else
    self.block = [self.block reverseBlock];
#endif
    [self layoutSubviews];
}

@end
