//
//  ViewController.m
//  NHCarouseler
//
//  Created by hu jiaju on 16/6/7.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "ViewController.h"
#import "NHCarouseler.h"
#import "NHFlagCell.h"
#import "NHTextCell.h"

@interface ViewController ()<NHCarouselerDelegate , NHCarouselerDataSource>

@property (nonatomic, strong, nullable) NHCarouseler *review;
@property (nonatomic, strong, nullable) NHCarouseler *textReview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect  infoRect= CGRectMake(0, 50, CGRectGetWidth(self.view.bounds), 200);
    _review = [[NHCarouseler alloc] initWithFrame:infoRect];
    _review.backgroundColor = [UIColor blueColor];
    _review.delegate = self;
    _review.dataSource = self;
    [self.view addSubview:_review];
    
    infoRect.origin.y += 220;
    _textReview = [[NHCarouseler alloc] initWithFrame:infoRect];
    _textReview.backgroundColor = [UIColor redColor];
    _textReview.delegate = self;
    _textReview.dataSource = self;
    [self.view addSubview:_textReview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- ReView --

- (NSInteger)numberOfRowsForCarouseler:(NHCarouseler *)carouseler {
    return 7;
}

- (NHCarouselerCell *)carouseler:(NHCarouseler *)view cellForRowIndex:(NSUInteger)index{
    
    if (view == _review) {
        NSLog(@"up section");
        static NSString *identifier = @"flagCell";
        NHFlagCell *cell = (NHFlagCell *)[view dequeueReusablePageWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[NHFlagCell alloc] initWithIdentifier:identifier];
        }
        
        cell.backgroundColor = [self randomColor];
        NSString *imgName = [NSString stringWithFormat:@"%zd",index+1];
        cell.image = [UIImage imageNamed:imgName];
        //NSLog(@"cell for row:%zd",index);
        return cell;
    }else if (view == _textReview){
        NSLog(@"down section");
        static NSString *identifier = @"textCell";
        NHTextCell *cell = (NHTextCell *)[view dequeueReusablePageWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[NHTextCell alloc] initWithIdentifier:identifier];
        }
        
        cell.backgroundColor = [self randomColor];
        NSString *imgName = [NSString stringWithFormat:@"这是第%zd",index+1];
        cell.text = imgName;
        //NSLog(@"cell for row:%zd",index);
        return cell;
    }
    
    return nil;
}

- (void)carouseler:(NHCarouseler *)view willDismissIndex:(NSUInteger)index{
    //NSLog(@"will dismiss index :%zd",index);
}

- (void)carouseler:(NHCarouseler *)view didChangeToIndex:(NSUInteger)index{
    //NSLog(@"did changed to index :%zd",index);
}

- (void)carouseler:(NHCarouseler *)view didSelectedIndex:(NSUInteger)index {
    NSLog(@"did touch to index :%zd",index);
}

-(UIColor *)randomColor{
    static BOOL seeded = NO;
    if (!seeded) {
        seeded = YES;
        srandom(time(NULL));
    }
    CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

@end
