//
//  NHCarouseler.m
//  NHCarouseler
//
//  Created by hu jiaju on 16/6/7.
//  Copyright © 2016年 hu jiaju. All rights reserved.
//

#import "NHCarouseler.h"

#pragma mark -- Cell --

@interface NHCarouselerCell ()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation NHCarouselerCell

- (NHCarouselerCell *)initWithIdentifier:(nonnull NSString *)identifier {
    self = [super init];
    if (self) {
        self.identifier = [identifier copy];
    }
    return self;
}

@end

#pragma mark -- TouchScroll
@protocol NHTouchScrollDelegate;
@interface NHTouchScroll : UIScrollView

@property (nonatomic, weak) id<NHTouchScrollDelegate> touchDelegate;

@end

@protocol NHTouchScrollDelegate <NSObject>

- (void)didTouchEndScroll:(NHTouchScroll*)scroll;

@end

@implementation NHTouchScroll

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_touchDelegate && [_touchDelegate respondsToSelector:@selector(didTouchEndScroll:)]) {
        [_touchDelegate didTouchEndScroll:self];
    }
}

@end

#pragma mark -- Carouseler --

@interface NHCarouseler ()<UIScrollViewDelegate, NHTouchScrollDelegate>

@property (nonatomic, strong) NHTouchScroll *scrollView;
@property (nonatomic, strong) NHCarouselerCell *prePage,*curPage,*nexPage;
@property (nonatomic, assign) NSUInteger prePageIdx,curPageIdx,nexPageIdx,pageCount;
@property (nonatomic, strong) NSMutableDictionary *identifierDict;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation NHCarouseler

- (void)dealloc {
    _identifierDict = nil;
    _scrollView = nil;
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.identifierDict = [NSMutableDictionary dictionary];
        self.pageCount = 0;
        self.curPage = 0;
        self.scrollView = [[NHTouchScroll alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3*CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        self.scrollView.delegate = self;
        self.scrollView.touchDelegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds), 0);
        self.scrollView.pagingEnabled = true;
        self.scrollView.showsHorizontalScrollIndicator = false;
        self.scrollView.scrollsToTop = false;
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)setDataSource:(id<NHCarouselerDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (NSMutableArray *)obtainCacheWithIdentifier:(NSString *)identifier{
    NSMutableArray *pageCacheArr = [_identifierDict objectForKey:identifier];
    if (pageCacheArr == nil || [pageCacheArr count] <= 0) {
        pageCacheArr = [NSMutableArray array];
        [_identifierDict setObject:pageCacheArr forKey:identifier];
    }
    //NSInteger count = [pageCacheArr count];
    //NSLog(@"reuse queue counts:%zd",count);
    return pageCacheArr;
}

- (NHCarouselerCell *)dequeueReusablePageWithIdentifier:(NSString *)identifier{
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:identifier];
    NHCarouselerCell *page = [pageCacheArr lastObject];
    NHCarouselerCell *dstCell ;
    if (page) {
        //NSLog(@"reuse old page");
        dstCell = page;
        [pageCacheArr removeLastObject];
    }/*else{
      NSLog(@"create new page");
      //        dstCell = [[NHReCell alloc] initWithIdentifier:identifier];
      dstCell = [_dataSource review:self pageViewAtIndex:index];
      }*/
    return dstCell;
}

- (void)queueReusablePageWithIdentifier:(NHCarouselerCell *)page {
    if (page == nil) {
        return;
    }
    NSMutableArray *pageCacheArr = [self obtainCacheWithIdentifier:page.identifier];
    [pageCacheArr addObject:page];
    [page removeFromSuperview];
}

- (void)setCurPageIdx:(NSUInteger)curPageIdx{
    _curPageIdx = curPageIdx;
    NSUInteger pageCount = [self pageCount];
    if (pageCount > 0) {
        _prePageIdx = _curPageIdx == 0 ? pageCount-1:_curPageIdx-1;
        _nexPageIdx = _curPageIdx == (pageCount - 1)? 0:_curPageIdx+1;
        if (_delegate && [_delegate respondsToSelector:@selector(carouseler:didChangeToIndex:)]) {
            [_delegate carouseler:self didChangeToIndex:curPageIdx];
        }
    }else{
        _prePageIdx = 0;
        _nexPageIdx = 0;
    }
}

- (NHCarouselerCell *)setupPageCell:(NSUInteger)pageIdx {
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NHCarouselerCell *cell = [_dataSource carouseler:self cellForRowIndex:pageIdx];
    return cell;
}

- (void)reloadData {
    [self invalidateTimer];
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    if ([_dataSource respondsToSelector:@selector(numberOfRowsForCarouseler:)]) {
        NSUInteger counts  = [self pageCount];
        if (counts > 0) {
            NHCarouselerCell *pageCell = [self setupPageCell:0];
            self.curPage = pageCell;
            self.curPageIdx = 0;
            self.curPage.frame = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
            [self.scrollView addSubview:self.curPage];
            
            [self launchTimer];
        }
    }
}

- (void)launchTimer {
    if (self.timer != nil) {
        return;
    }
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeFired) userInfo:nil repeats:true];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)invalidateTimer {
    if (_timer != nil) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

- (void)timeFired {
    [self nextPage];
}

- (NSUInteger)pageCount{
    NSAssert(_dataSource != nil, @"datasource can not be nil!");
    NSUInteger counts = [_dataSource numberOfRowsForCarouseler:self];
    //NSAssert(counts > 0, @"review page number must more than one !");
    return counts;
}

- (void)prefPage {
    CGSize pageSize = self.scrollView.bounds.size;
    CGPoint offset = self.scrollView.contentOffset;
    offset.x -= pageSize.width;
    [self.scrollView setContentOffset:offset animated:true];
}

- (void)nextPage {
    CGSize pageSize = self.scrollView.bounds.size;
    CGPoint offset = self.scrollView.contentOffset;
    offset.x += pageSize.width;
    [self.scrollView setContentOffset:offset animated:true];
}

#pragma mark -- ScrollView Delegate --

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging) {
        [self invalidateTimer];
    }
    float contentOffset_x = scrollView.contentOffset.x;
    if (contentOffset_x > scrollView.bounds.size.width) {
        /// add the pre page to cache
        [self queueReusablePageWithIdentifier:self.prePage];
        self.prePage = nil;
        ///display the next page
        if (self.nexPage == nil) {
            NHCarouselerCell *nexPage = [self setupPageCell:_nexPageIdx];
            CGRect infoRect = CGRectMake(self.curPage.frame.origin.x + self.curPage.frame.size.width, 0, self.curPage.frame.size.width, self.curPage.frame.size.height);
            nexPage.frame = infoRect;
            [self.scrollView addSubview:nexPage];
            self.nexPage = nexPage;
        }
    }else if (contentOffset_x < scrollView.bounds.size.width) {
        /// add the next page to cache
        [self queueReusablePageWithIdentifier:self.nexPage];
        self.nexPage = nil;
        ///display the pre page
        if (self.prePage == nil) {
            NHCarouselerCell *prePage = [self setupPageCell:_prePageIdx];
            CGRect infoRect = CGRectMake(self.curPage.frame.origin.x - self.curPage.frame.size.width, 0, self.curPage.frame.size.width, self.curPage.frame.size.height);
            prePage.frame = infoRect;
            [self.scrollView addSubview:prePage];
            self.prePage = prePage;
        }
    }
    
    if (contentOffset_x >= CGRectGetWidth(scrollView.frame)*2) {
        /// add the current page to cache and make the current page to next page
        [self queueReusablePageWithIdentifier:self.curPage];
        self.curPage = self.nexPage;
        self.nexPage = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(carouseler:willDismissIndex:)]) {
            [_delegate carouseler:self willDismissIndex:self.curPageIdx];
        }
        self.curPageIdx = self.nexPageIdx;
        [self scrollViewDidEndDecelerating:scrollView];
    }else if (contentOffset_x <= 0){
        [self queueReusablePageWithIdentifier:self.curPage];
        self.curPage  = self.prePage;
        self.prePage = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(carouseler:willDismissIndex:)]) {
            [_delegate carouseler:self willDismissIndex:self.curPageIdx];
        }
        self.curPageIdx = self.prePageIdx;
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0)];
    CGRect infoRect = CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.curPage.frame = infoRect;
    
    if (!scrollView.isDragging) {
        [self launchTimer];
    }
}

#pragma mark -- Touch Delegate

- (void)didTouchEndScroll:(NHTouchScroll *)scroll {
    if (_delegate && [_delegate respondsToSelector:@selector(carouseler:didSelectedIndex:)]) {
        [_delegate carouseler:self didSelectedIndex:self.curPageIdx];
    }
}

@end
