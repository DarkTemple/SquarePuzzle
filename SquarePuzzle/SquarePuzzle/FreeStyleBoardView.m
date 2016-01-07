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

static const int kLineViewTag = 31415;

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
        
        // add stepper
        UIStepper *stepper = [[UIStepper alloc] init];
        [stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
        stepper.value = 12;
        stepper.minimumValue = 3;
        stepper.maximumValue = 12;
        stepper.frame = CGRectMake(30, 62, 100, 100);
        [self addSubview:stepper];
        
        // draw board
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat gridWidth = (screenWidth - 60.f)/width;
        _boardStartPoint = CGPointMake(30, 100);
        
        [self drawGridLinesWithWidth:12];

        CGFloat maxY = _boardStartPoint.y + height*gridWidth;
        CGFloat x = 10.f;
        CGFloat y = maxY + 20.f;
        
        for (int i=0; i<self.allBlocks.count; i++) {
            BlockView *blockView = [self.allBlocks[i] generateBlockViewWithWidth:gridWidth];
            blockView.startPoint = _boardStartPoint;
            CGFloat width = CGRectGetWidth(blockView.frame);
            CGFloat height = CGRectGetHeight(blockView.frame);
            blockView.frame = CGRectMake(x+(i%3)*gridWidth*5, i/3*gridWidth*4+y, width, height);
            [self addSubview:blockView];
        }
    }
    
    return self;
}

- (void)drawGridLinesWithWidth:(int)width
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == kLineViewTag) {
            [obj removeFromSuperview];
        }
    }];
    
    // draw board
    static const int kMaxWidth = 12;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat gridWidth = (screenWidth - 60.f)/kMaxWidth;
    _boardStartPoint = CGPointMake(30, 100);
    CGFloat maxY = 0;
    
    for (int i=0; i<height+1; i++) {
        UIView *xLine = [[UIView alloc] initWithFrame:CGRectMake(_boardStartPoint.x, _boardStartPoint.y+i*gridWidth, gridWidth*width, kLineWidth)];
        xLine.tag = kLineViewTag;
        xLine.backgroundColor = [UIColor blackColor];
        [self addSubview:xLine];
        maxY = CGRectGetMaxY(xLine.frame);
    }
    
    for (int i=0; i<width+1; i++) {
        UIView *yLine = [[UIView alloc] initWithFrame:CGRectMake(_boardStartPoint.x+i*gridWidth, _boardStartPoint.y, kLineWidth, gridWidth*height)];
        yLine.tag = kLineViewTag;
        yLine.backgroundColor = [UIColor blackColor];
        [self addSubview:yLine];
    }

}

- (void)stepperChanged:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    [self drawGridLinesWithWidth:stepper.value];
}

@end
