//
//  BlockView.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "BlockView.h"
#import "SquareBlock.h"

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
}

- (void)moveBlock:(UIPanGestureRecognizer *)panGR
{
    CGPoint translation = [panGR translationInView:self];
    panGR.view.center = CGPointMake(panGR.view.center.x + translation.x,
                                         panGR.view.center.y + translation.y);
    [panGR setTranslation:CGPointZero inView:self];
    if (panGR.state == UIGestureRecognizerStateChanged) {
        self.alpha = .3f;
    } else {
        self.alpha = 1.f;
    }
    
    if (panGR.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"%@", NSStringFromCGPoint(self.frame.origin));
        CGFloat x = self.startPoint.x + roundf(((CGRectGetMinX(self.frame) - self.startPoint.x) / self.gridWidth)) * self.gridWidth;
        CGFloat y = self.startPoint.y + roundf(((CGRectGetMinY(self.frame) - self.startPoint.y) / self.gridWidth)) * self.gridWidth;
        self.frame = CGRectMake(x, y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
}

- (void)tapBlock1:(UITapGestureRecognizer *)tapGR
{
    NSLog(@"Roatate clockwise!");
    [self.block rotateClockwiseInplace];
    [self layoutSubviews];
}

- (void)tapBlock2:(UITapGestureRecognizer *)tapGR
{
    NSLog(@"Reverse clockwise!");
    [self.block reverseBlockInplace];
    [self layoutSubviews];
}


@end
