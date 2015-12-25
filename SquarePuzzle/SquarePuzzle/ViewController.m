//
//  ViewController.m
//  SquarePuzzle
//
//  Created by Haoquan Bai on 15/12/25.
//  Copyright © 2015年 Alipay. All rights reserved.
//

#import "ViewController.h"
#import "SquarePuzzleSolver.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSMutableArray <NSMutableArray <SquareUnit *> *> *squareArr = [NSMutableArray array];
//    for (int i=0; i<3; i++) {
//        NSMutableArray <SquareUnit *>*rowArr = [NSMutableArray array];
//        for (int i=0; i<5; i++) {
//            [rowArr addObject:[SquareUnit new]];
//        }
//        
//        [squareArr addObject:rowArr];
//    }
//    
//    
//    squareArr[0][0].unitState = SquareUnitStateFull;
//    squareArr[0][2].unitState = SquareUnitStateFull;
//    squareArr[0][3].unitState = SquareUnitStateFull;
//    
//    squareArr[1][1].unitState = SquareUnitStateFull;
//    squareArr[1][3].unitState = SquareUnitStateFull;
//    
//    squareArr[2][2].unitState = SquareUnitStateFull;
//    squareArr[2][4].unitState = SquareUnitStateFull;
//    
//    SquareBlock *block = [[SquareBlock alloc] initWithSquarShapeArr:squareArr];
//    [block printSquare];
    
    
//    [[[unit rotateClockwise] rotateClockwise] printSquare];
    SquarePuzzleSolver *solver = [[SquarePuzzleSolver alloc] initWithBorderWidth:5 height:4];
    
    // block1
    NSMutableArray <NSMutableArray <SquareUnit *> *> *shapeArr = [NSMutableArray squareArrayWithWidth:2 height:3];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    shapeArr[2][0].unitState = SquareUnitStateFull;
    SquareBlock *block1 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr];
    
    // block2
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:2];
    shapeArr[0][0].unitState = SquareUnitStateFull;
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    SquareBlock *block2 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr];

    // block3
    shapeArr = [NSMutableArray squareArrayWithWidth:4 height:2];
    shapeArr[0][1].unitState = SquareUnitStateFull;
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[0][3].unitState = SquareUnitStateFull;
    shapeArr[1][0].unitState = SquareUnitStateFull;
    shapeArr[1][1].unitState = SquareUnitStateFull;
    SquareBlock *block3 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr];

    // block4
    shapeArr = [NSMutableArray squareArrayWithWidth:3 height:3];
    shapeArr[0][2].unitState = SquareUnitStateFull;
    shapeArr[1][2].unitState = SquareUnitStateFull;
    shapeArr[2][0].unitState = SquareUnitStateFull;
    shapeArr[2][1].unitState = SquareUnitStateFull;
    shapeArr[2][2].unitState = SquareUnitStateFull;
    SquareBlock *block4 = [[SquareBlock alloc] initWithSquarShapeArr:shapeArr];
    
    [solver addSquareUnit:block1];
    [solver addSquareUnit:block2];
    [solver addSquareUnit:block3];
    [solver addSquareUnit:block4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
