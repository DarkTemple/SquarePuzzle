//
//  ViewController.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "ViewController.h"
#import "SquarePuzzleSolver.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "FreeStyleBoardView.h"

//#define <#macro#>


typedef void (*Func)(id sender, SEL sel, ...);

static const NSTimeInterval kToastDuration = 1.f;

#define LOOP 90000000
#define START { clock_t start, end; start = clock();
#define END end = clock(); \
printf("Cost:%f\n", (double)(end - start) / CLOCKS_PER_SEC * 1000); }

@interface ViewController ()
@property (nonatomic, strong) NSArray <UIView *> *allSolViews;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray <SquareBlock *> *allBlocks;
@property (nonatomic, strong) UISegmentedControl *segCtrl;
@property (nonatomic, strong) FreeStyleBoardView *freeBoardView;
@end

@implementation ViewController

- (void)_functionCall{
    // Do nothing...
}

- (void)testObjectiveCMethod {
    START
    for (NSUInteger i = 0; i < LOOP; ++i) {
        [self _functionCall];
    }
    END  
}

- (void)testCCall {
    SEL sel = @selector(_functionCall);
    IMP imp = [self methodForSelector:@selector(_functionCall)];
    START
    for (NSUInteger i = 0; i < LOOP; ++i) {
        ((void (*)(id sender, SEL sel, ...))imp)(self, sel);
    }
    END  
}

- (void)testArrayCountTime
{
    NSInteger matrixN = 100000;
    NSMutableArray <NSMutableArray <NSNumber *> *> *squareArr = [NSMutableArray arrayWithCapacity:matrixN];
    for (int i=0; i<matrixN; i++) {
        NSMutableArray <NSNumber *> *rowArr = [NSMutableArray arrayWithCapacity:matrixN];
        for (int j=0; j<matrixN; j++) {
            [rowArr addObject:@1];
        }
        
        [squareArr addObject:rowArr];
    }
    
    START
    NSInteger testLoopCount = 100;
    for (int k=0; k<testLoopCount; k++) {
        for (int i=0; i<matrixN; i++) {
            for (int j=0; j<matrixN; j++) {
                NSUInteger l1 = squareArr.count;
                NSUInteger l2 = squareArr[0].count;
            }
        }
    }
    END
    
    START
    NSInteger testLoopCount = 100;
    for (int k=0; k<testLoopCount; k++) {
        for (int i=0; i<matrixN; i++) {
            for (int j=0; j<matrixN; j++) {
                NSNumber *x = squareArr[i][j];
                x = @2;
            }
        }
    }
    END
}

- (void)testMatrixVisitARC
{
    START
    int n = 10;
    int loop = 500000;
    SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:n height:n minBlockUnitCount:5];
    __unsafe_unretained NSArray <NSArray <SquareUnit *> *> *squareBoardArr = solver.unitArr;
    int height = solver.height;
    int width = solver.width;
    
    for (int l=0; l<loop; l++) {
        for (int i=0; i<height; i++) {
            __unsafe_unretained NSArray <SquareUnit *> *tempArr = squareBoardArr[i];
            for (int j=0; j<width; j++) {
                __unsafe_unretained SquareUnit *squareBlock = tempArr[j];
                squareBlock->_unitState = SquareUnitStateVisited;
//                tempArr[j].unitState = SquareUnitStateVisited;
//                [tempArr[j] setUnitState:SquareUnitStateVisited];
//                squareBoardArr[i][j].unitState = SquareUnitStateVisited;
//                solver.unitArr[i][j].unitState = SquareUnitStateVisited;
            }
        }
    }
    
    END
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self testObjectiveCMethod];
//    [self testCCall];
//    return;
//    [self testArrayCountTime];
//    return;
    
//    [self testMatrixVisitARC];
//    return;

//    return;
    
    [self _initAllBlocks];
    
    self.segCtrl = [[UISegmentedControl alloc] initWithItems:@[@"FreeStyle", @"Case1", @"Case2", @"Case3", @"Solutions"]];
    [self.segCtrl addTarget:self action:@selector(segSelected:) forControlEvents:UIControlEventValueChanged];
    self.segCtrl.frame = CGRectMake((CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.segCtrl.frame))/2, 30, CGRectGetWidth(self.segCtrl.frame), CGRectGetHeight(self.segCtrl.frame));
    self.segCtrl.selectedSegmentIndex = 0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.pagingEnabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.freeBoardView = [[FreeStyleBoardView alloc] initWithBlocks:self.allBlocks];
    
//    [self testCase1];
    [self freeStyle];
    
}

- (void)segSelected:(id)sender
{
    NSInteger index = self.segCtrl.selectedSegmentIndex;
    
    if (index != 0) {
        [self.freeBoardView removeFromSuperview];
        [self.segCtrl removeFromSuperview];
    } else {
        [self.scrollView removeFromSuperview];
        [self.segCtrl removeFromSuperview];
    }
    
    switch (index) {
        case 0:
            [self freeStyle];
            break;
        case 1:
            [self testCase1];
            break;
        case 2:
            [self testCase3];
            break;
        case 3:
            [self testCase4];
            break;
        case 4:
            [self showAllSolutions];
            break;
        default:
            break;
    }
}

- (void)freeStyle
{
    [self.view addSubview:self.freeBoardView];
    [self.view addSubview:self.segCtrl];
}

- (void)showAllSolutions
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.scrollView removeFromSuperview];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:12 height:5 minBlockUnitCount:5];
        [self.allBlocks enumerateObjectsUsingBlock:^(SquareBlock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [solver addSquareUnit:obj];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSMutableSet *allSols = [NSMutableSet set];
            NSString *contentPath = [[NSBundle mainBundle] pathForResource:@"AllSolutions" ofType:@"txt"];
            NSString *txtContent = [NSString stringWithContentsOfFile:contentPath encoding:NSUTF8StringEncoding error:nil];
            
            static const int kShowAllSolsCount = 100;
            NSArray <NSString *> *allRawLines = [txtContent componentsSeparatedByString:@"\n"];
            [allRawLines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *solutionString = [obj substringFromIndex:[obj rangeOfString:@"]"].location+2];
                [allSols addObject:solutionString];
                
                if (idx > kShowAllSolsCount) {
                    *stop = YES;
                }
            }];
            
            [solver setSolutions:allSols];
            
            self.allSolViews = [solver generateSolutionGridViews];
            NSInteger solCount = self.allSolViews.count;
            self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*solCount, 0);
            [self.allSolViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat yOffset = (CGRectGetHeight(self.view.frame)-CGRectGetHeight(obj.frame))/2;
                CGFloat xOffset = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(obj.frame))/2;
                obj.frame = CGRectMake(CGRectGetWidth(self.view.frame)*idx+xOffset, yOffset, obj.frame.size.width, obj.frame.size.height);
                [self.scrollView addSubview:obj];
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:17.f];
                [label setText:[NSString stringWithFormat:@"%ld", idx+1]];
                [label sizeToFit];
                label.frame = CGRectMake(CGRectGetMinX(obj.frame), CGRectGetMaxY(obj.frame)+10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                [self.scrollView addSubview:label];
            }];
            
            [self.scrollView setContentOffset:CGPointZero];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.segCtrl];
        });
    });
}

- (void)testCase1
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.scrollView removeFromSuperview];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:3 height:5 minBlockUnitCount:5];
        [solver addSquareUnit:self.allBlocks[1]];
        [solver addSquareUnit:self.allBlocks[5]];
        [solver addSquareUnit:self.allBlocks[9]];
        
        NSTimeInterval begin, end, time;
        begin = CACurrentMediaTime();
        [solver solvePuzzle];
        end = CACurrentMediaTime();
        time = end - begin;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            self.allSolViews = [solver generateSolutionGridViews];
            NSInteger solCount = self.allSolViews.count;
            self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*solCount, 0);
            [self.allSolViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat yOffset = (CGRectGetHeight(self.view.frame)-CGRectGetHeight(obj.frame))/2;
                CGFloat xOffset = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(obj.frame))/2;
                obj.frame = CGRectMake(CGRectGetWidth(self.view.frame)*idx+xOffset, yOffset, obj.frame.size.width, obj.frame.size.height);
                [self.scrollView addSubview:obj];
                
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:17.f];
                [label setText:[NSString stringWithFormat:@"%ld", idx+1]];
                [label sizeToFit];
                label.frame = CGRectMake(CGRectGetMinX(obj.frame), CGRectGetMaxY(obj.frame)+10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                [self.scrollView addSubview:label];
            }];
            
            [self.scrollView setContentOffset:CGPointZero];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.segCtrl];

            [self.view makeToast:[NSString stringWithFormat:@"Elapsed time : %f ms", time*1000] duration:kToastDuration position:CSToastPositionCenter];
            NSLog(@"Elapsed time : %f ms", time*1000);
        });
    });
}

- (void)testCase2
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.scrollView removeFromSuperview];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:4 height:5 minBlockUnitCount:5];
        
        SquareBlock *blcok2 = self.allBlocks[1];
        SquareBlock *blcok6 = self.allBlocks[5];
        SquareBlock *blcok10 = self.allBlocks[9];
        SquareBlock *blcok12 = self.allBlocks[11];
        
        [solver addSquareUnit:blcok2];
        [solver addSquareUnit:blcok6];
        [solver addSquareUnit:blcok10];
        [solver addSquareUnit:blcok12];
        
        NSTimeInterval begin, end, time;
        begin = CACurrentMediaTime();
        [solver solvePuzzle];
        end = CACurrentMediaTime();
        time = end - begin;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            self.allSolViews = [solver generateSolutionGridViews];
            NSInteger solCount = self.allSolViews.count;
            self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*solCount, 0);
            [self.allSolViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat yOffset = (CGRectGetHeight(self.view.frame)-CGRectGetHeight(obj.frame))/2;
                CGFloat xOffset = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(obj.frame))/2;
                obj.frame = CGRectMake(CGRectGetWidth(self.view.frame)*idx+xOffset, yOffset, obj.frame.size.width, obj.frame.size.height);
                [self.scrollView addSubview:obj];
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:17.f];
                [label setText:[NSString stringWithFormat:@"%ld", idx+1]];
                [label sizeToFit];
                label.frame = CGRectMake(CGRectGetMinX(obj.frame), CGRectGetMaxY(obj.frame)+10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                [self.scrollView addSubview:label];
            }];
            
            [self.scrollView setContentOffset:CGPointZero];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.segCtrl];
            
            [self.view makeToast:[NSString stringWithFormat:@"Elapsed time : %f ms", time*1000] duration:kToastDuration position:CSToastPositionCenter];
            NSLog(@"Elapsed time : %f ms", time*1000);
        });
    });
}

- (void)testCase3
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.scrollView removeFromSuperview];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:6 height:5 minBlockUnitCount:5];

        SquareBlock *block2 = self.allBlocks[1];
        SquareBlock *block4 = self.allBlocks[3];
        SquareBlock *block6 = self.allBlocks[5];
        SquareBlock *block10 = self.allBlocks[9];
        SquareBlock *block11 = self.allBlocks[10];
        SquareBlock *block12 = self.allBlocks[11];
        
        [solver addSquareUnit:block2];
        [solver addSquareUnit:block4];
        [solver addSquareUnit:block6];
        [solver addSquareUnit:block10];
        [solver addSquareUnit:block11];
        [solver addSquareUnit:block12];
        
        NSTimeInterval begin, end, time;
        begin = CACurrentMediaTime();
        [solver solvePuzzle];
        end = CACurrentMediaTime();
        time = end - begin;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            self.allSolViews = [solver generateSolutionGridViews];
            NSInteger solCount = self.allSolViews.count;
            self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*solCount, 0);
            [self.allSolViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat yOffset = (CGRectGetHeight(self.view.frame)-CGRectGetHeight(obj.frame))/2;
                CGFloat xOffset = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(obj.frame))/2;
                obj.frame = CGRectMake(CGRectGetWidth(self.view.frame)*idx+xOffset, yOffset, obj.frame.size.width, obj.frame.size.height);
                [self.scrollView addSubview:obj];
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:17.f];
                [label setText:[NSString stringWithFormat:@"%ld", idx+1]];
                [label sizeToFit];
                label.frame = CGRectMake(CGRectGetMinX(obj.frame), CGRectGetMaxY(obj.frame)+10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                [self.scrollView addSubview:label];
            }];
            
            [self.scrollView setContentOffset:CGPointZero];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.segCtrl];
            
            [self.view makeToast:[NSString stringWithFormat:@"Elapsed time : %f ms", time*1000] duration:kToastDuration position:CSToastPositionCenter];
            NSLog(@"Elapsed time : %f ms", time*1000);
        });
    });
}

- (void)testCase4
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.scrollView removeFromSuperview];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:12 height:5 minBlockUnitCount:5];
        
        [self.allBlocks enumerateObjectsUsingBlock:^(SquareBlock * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [solver addSquareUnit:obj];
        }];
        
        NSTimeInterval begin, end, time;
        begin = CACurrentMediaTime();
        [solver solvePuzzle];
        end = CACurrentMediaTime();
        time = end - begin;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            
            self.allSolViews = [solver generateSolutionGridViews];
            NSInteger solCount = self.allSolViews.count;
            self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame)*solCount, 0);
            [self.allSolViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGFloat yOffset = (CGRectGetHeight(self.view.frame)-CGRectGetHeight(obj.frame))/2;
                CGFloat xOffset = (CGRectGetWidth(self.view.frame)-CGRectGetWidth(obj.frame))/2;
                obj.frame = CGRectMake(CGRectGetWidth(self.view.frame)*idx+xOffset, yOffset, obj.frame.size.width, obj.frame.size.height);
                [self.scrollView addSubview:obj];
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:17.f];
                [label setText:[NSString stringWithFormat:@"%ld", idx+1]];
                [label sizeToFit];
                label.frame = CGRectMake(CGRectGetMinX(obj.frame), CGRectGetMaxY(obj.frame)+10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame));
                [self.scrollView addSubview:label];
            }];
            
            [self.scrollView setContentOffset:CGPointZero];
            [self.view addSubview:self.scrollView];
            [self.view addSubview:self.segCtrl];
            
            [self.view makeToast:[NSString stringWithFormat:@"Elapsed time : %f ms", time*1000] duration:kToastDuration position:CSToastPositionCenter];
            NSLog(@"Elapsed time : %f ms", time*1000);
        });
    });
}


- (void)_initAllBlocks
{
    self.allBlocks = [NSMutableArray array];
    
    // block1
    NSMutableArray <NSMutableArray <SquareUnit *> *> *shapeArr = [NSMutableArray squareArrayWithWidth:5 height:1];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[0][3].unitState = SquareUnitStateFull;
    shapeArr[0][4].unitState = SquareUnitStateFull;
    SquareBlock *block1 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:5 height:1];
    block1.blockID = 1;
    block1.blockColor = [UIColor colorWithRed:225/255.f green:190/255.f blue:224/255.f alpha:1];
    
    // block2
    shapeArr = [NSMutableArray squareArrayWithWidth:4 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[1][3].unitState = SquareUnitStateFull;
    SquareBlock *block2 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:4 height:2];
    block2.blockID = 2;
    block2.blockColor = [UIColor colorWithRed:241/255.f green:99/255.f blue:1/255.f alpha:1];
    
    // block3
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    SquareBlock *block3 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:2];
    block3.blockID = 3;
    block3.blockColor = [UIColor colorWithRed:211/255.f green:178/255.f blue:67/255.f alpha:1];
    
    // block4
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[2][0].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    SquareBlock *block4 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block4.blockID = 4;
    block4.blockColor = [UIColor colorWithRed:173/255.f green:38/255.f blue:94/255.f alpha:1];
    
    // block5
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[2][0].unitState = SquareUnitStateFull;
    SquareBlock *block5 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block5.blockID = 5;
    block5.blockColor = [UIColor colorWithRed:4/255.f green:108/255.f blue:193/255.f alpha:1];
    
    // block6
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    SquareBlock *block6 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block6.blockID = 6;
    block6.blockColor = [UIColor colorWithRed:41/255.f green:158/255.f blue:70/255.f alpha:1];
    //    [block6 printSquare];
    
    // block7
//    shapeArr = [NSMutableArray squareArrayWithWidth:1 height:5];
//    shapeArr[0][0].unitState = SquareUnitStateFull;
//    shapeArr[1][0].unitState = SquareUnitStateFull;
//    shapeArr[2][0].unitState = SquareUnitStateFull;
//    shapeArr[3][0].unitState = SquareUnitStateFull;
//    shapeArr[4][0].unitState = SquareUnitStateFull;
//    SquareBlock *block7 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:1 height:5];
//    block7.blockID = @"7";
//    block7.blockColor = [UIColor colorWithRed:197/255.f green:186/255.f blue:182/255.f alpha:1];
    //    [block7 printSquare];
    
    // block7
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    SquareBlock *block7 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block7.blockID = 7;
    block7.blockColor = [UIColor colorWithRed:253/255.f green:231/255.f blue:57/255.f alpha:1];
    //    [block8 printSquare];
    
    // block8
    shapeArr = [NSMutableArray squareArrayWithWidth:4 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[1][3].unitState = SquareUnitStateFull;
    SquareBlock *block8 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:4 height:2];
    block8.blockID = 8;
    block8.blockColor = [UIColor colorWithRed:15/255.f green:11/255.f blue:12/255.f alpha:1];
    //    [block9 printSquare];
    
    // block9
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    SquareBlock *block9 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block9.blockID = 9;
    block9.blockColor = [UIColor colorWithRed:227/255.f green:3/255.f blue:3/255.f alpha:1];
    //    [block10 printSquare];
    
    // block10
    shapeArr = [NSMutableArray squareArrayWithWidth:4 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[0][3].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    SquareBlock *block10 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:4 height:2];
    block10.blockID = 10;
    block10.blockColor = [UIColor colorWithRed:91/255.f green:39/255.f blue:17/255.f alpha:1];
    //    [block11 printSquare];
    
    // block11
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    shapeArr[2][2].unitState = SquareUnitStateFull;
    SquareBlock *block11 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:3];
    block11.blockID = 11;
    block11.blockColor = [UIColor colorWithRed:183/255.f green:183/255.f blue:182/255.f alpha:1];
    //    [block12 printSquare];
    
    // block12
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    SquareBlock *block12 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr width:3 height:2];
    block12.blockID = 12;
    block12.blockColor = [UIColor colorWithRed:104/255.f green:186/255.f blue:226/255.f alpha:1];
    
    [self.allBlocks addObject:block1];
    [self.allBlocks addObject:block2];
    [self.allBlocks addObject:block3];
    [self.allBlocks addObject:block4];
    [self.allBlocks addObject:block5];
    [self.allBlocks addObject:block6];
    [self.allBlocks addObject:block7];
    [self.allBlocks addObject:block8];
    [self.allBlocks addObject:block9];
    [self.allBlocks addObject:block10];
    [self.allBlocks addObject:block11];
    [self.allBlocks addObject:block12];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
