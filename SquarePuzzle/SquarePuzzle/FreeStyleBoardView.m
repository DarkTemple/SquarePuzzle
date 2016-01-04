//
//  FreeStyleBoardView.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 16/1/4.
//  Copyright © 2016年 Alipay. All rights reserved.
//

#import "FreeStyleBoardView.h"

static const int width = 12;
static const int height = 5;

@interface FreeStyleBoardView ()
@property (nonatomic, strong) NSMutableArray <SquareBlock *> *allBlocks;
//@property (nonatomic, strong) UIScrollView *blockScrollView;
@property (nonatomic) CGPoint boardStartPoint;
@end

@implementation FreeStyleBoardView

- (instancetype)initWithBlocks:(NSArray <SquareBlock *> *)blocks
{
    if (self = [super init]) {
        self.allBlocks = [NSMutableArray arrayWithCapacity:blocks.count];
        [blocks enumerateObjectsUsingBlock:^(SquareBlock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.allBlocks addObject:[obj copy]];
        }];
        
        self.frame = [UIScreen mainScreen].bounds;
        // draw board
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat gridWidth = (screenWidth - 60.f)/width;
        _boardStartPoint = CGPointMake(30, 200);
        CGFloat maxY = 0;
        
        for (int i=0; i<height+1; i++) {
            UIView *xLine = [[UIView alloc] initWithFrame:CGRectMake(_boardStartPoint.x, _boardStartPoint.y+i*gridWidth, (screenWidth - 60.f), kLineWidth)];
            xLine.backgroundColor = [UIColor blackColor];
            [self addSubview:xLine];
            maxY = CGRectGetMaxY(xLine.frame);
        }

        for (int i=0; i<width+1; i++) {
            UIView *yLine = [[UIView alloc] initWithFrame:CGRectMake(_boardStartPoint.x+i*gridWidth, _boardStartPoint.y, kLineWidth, gridWidth*height)];
            yLine.backgroundColor = [UIColor blackColor];
            [self addSubview:yLine];
        }
        
        // add scroll view
//        _blockScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.frame)-200, CGRectGetWidth(self.frame)-40, 180)];
//        _blockScrollView.layer.borderWidth = 1;
//        [self addSubview:_blockScrollView];
        
        CGFloat x = 10.f;
        CGFloat y = maxY + 10.f;
        
        for (int i=0; i<self.allBlocks.count; i++) {
            UIView *blockView = [self.allBlocks[i] generateBlockViewWithWidth:gridWidth];
            CGFloat width = CGRectGetWidth(blockView.frame);
            CGFloat height = CGRectGetHeight(blockView.frame);
            blockView.frame = CGRectMake(x+(i%3)*gridWidth*5, i/3*gridWidth*3+y, width, height);
            [self addSubview:blockView];
        }
    }
    
    return self;
}

@end
