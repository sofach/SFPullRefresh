//
//  UIScrollView+SFPullRefresh.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//
#import <objc/runtime.h>

#import "UIScrollView+SFPullRefresh.h"

@interface SFPullRefreshContext : NSObject

@property (weak, nonatomic) UIScrollView *owner;
@property (assign, nonatomic) NSUInteger page;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL autoLoading;
@property (assign, nonatomic) UIEdgeInsets orignInset;

- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void(^)(void))refreshHandler atPosition:(SFPullRefreshPosition)position;

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void(^)(void))loadMoreHandler atPosition:(SFPullRefreshPosition)position;

- (void)refreshAnimated:(BOOL)animated;

- (void)loadMoreAnimated:(BOOL)animated;

- (void)reachEndWithText:(NSString *)text;

- (void)finishLoading;

- (void)showHints:(NSString *)hints;
- (void)showHintsView:(UIView *)hintsView;

- (void)setControlColor:(UIColor *)controlColor;

- (void)addObservers;

- (void)removeObservers;

@end

@interface UIScrollView ()

@property (strong, nonatomic) SFPullRefreshContext *context;

@end

@implementation UIScrollView (SFPullRefresh)

#pragma mark getter setter
- (SFPullRefreshContext *)context {
    return objc_getAssociatedObject(self, @selector(context));
}

- (void)setContext:(SFPullRefreshContext *)context {
    [self willChangeValueForKey:@"context"]; // KVO
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"context"]; // KVO
}

#pragma mark - public method
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler {
    [self sf_addRefreshHandler:refreshHandler position:SFPullRefreshPositionTop];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position {
    [self sf_addRefreshHandler:refreshHandler position:position customRefreshControl:nil];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl {
    if (![self respondsToSelector:@selector(backgroundView)]) {
        return;
    }
    
    if (!self.context) {
        self.context = [[SFPullRefreshContext alloc] init];
        self.context.owner = self;
    }
    
    if (!customRefreshControl) {
        customRefreshControl = [[SFRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    }
    
    [self.context setRefreshControl:customRefreshControl withRefreshHandler:refreshHandler atPosition:position];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler {
    [self sf_addLoadMoreHandler:loadMoreHandler position:SFPullRefreshPositionBottom];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position {
    [self sf_addLoadMoreHandler:loadMoreHandler position:position customLoadMoreControl:nil];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl {
    if (!self.context) {
        self.context = [[SFPullRefreshContext alloc] init];
        self.context.owner = self;
    }

    if (!customLoadMoreControl) {
        customLoadMoreControl = [[SFLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 49)];
    }
    [self.context setLoadMoreControl:customLoadMoreControl withLoadMoreHandler:loadMoreHandler atPosition:position];
}

- (BOOL)sf_isRefreshing {
    return self.context.isRefreshing;
}

- (NSUInteger)sf_page {
    return self.context.page;
}

- (void)sf_finishLoading {
    [self.context finishLoading];
}

- (void)sf_refreshAnimated:(BOOL)animated {
    [self.context refreshAnimated:animated];
}

- (void)sf_loadMoreAnimated:(BOOL)animated {
    [self.context loadMoreAnimated:animated];
}

- (void)sf_reachEndWithText:(NSString *)text {
    [self.context reachEndWithText:text];
}

- (void)sf_showHints:(NSString *)hints {
    [self.context showHints:hints];
}

- (void)sf_showHintsView:(UIView *)hintsView {
    [self.context showHintsView:hintsView];
}

- (void)sf_setControlColor:(UIColor *)controlColor {
    [self.context setControlColor:controlColor];
}

- (void)sf_willMoveToSuperview:(UIView *)newSuperView {
    [self sf_willMoveToSuperview:newSuperView];
    
    if (self.context) {
        
        if (self.superview) {
            [self.context removeObservers];
        }
        if (newSuperView) {
            [self.context addObservers];
            self.context.orignInset = self.contentInset;
        }
    }
}

@end















typedef enum {
    SFPullRefreshStateNormal = 0,
    SFPullRefreshStatePullToRefresh,
    SFPullRefreshStateReleaseToRefresh,
    SFPullRefreshStateRefreshing,
    SFPullRefreshStateLoading,
    SFPullRefreshStateReachEnd
} SFPullRefreshState;

#pragma mark SFPullRefreshContext implementation
@interface SFPullRefreshContext ()

@property (assign, nonatomic) CGFloat preHeight;

@property (assign, nonatomic) SFPullRefreshState refreshState;
@property (assign, nonatomic) SFPullRefreshState loadMoreState;

@property (assign, nonatomic) SFPullRefreshPosition refreshPosition;
@property (assign, nonatomic) SFPullRefreshPosition loadMorePosition;

@property (copy, nonatomic) void (^refreshHandler)(void);
@property (copy, nonatomic) void (^loadMoreHandler)(void);

@property (strong, nonatomic) UIView <SFRefreshControlDelegate> * refreshControl;
@property (strong, nonatomic) UIView <SFLoadMoreControlDelegate> * loadMoreControl;

@property (strong, nonatomic) UILabel *hintsLabel;
@property (strong, nonatomic) UIView *hintsView;

@end

@implementation SFPullRefreshContext

- (id)init
{
    self = [super init];
    if (self) {
        _page = 0;
        _preHeight = 0;
        _autoLoading = YES;
        _orignInset.left = CGFLOAT_MAX;
        _refreshPosition = SFPullRefreshPositionTop;
        _loadMorePosition = SFPullRefreshPositionBottom;
    }
    return self;
}



#pragma mark - getter setter
- (UILabel *)hintsLabel {
    if (!_hintsLabel) {
        _hintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _owner.frame.size.width, _owner.frame.size.height-_orignInset.top-_orignInset.bottom)];
        _hintsLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        _hintsLabel.textAlignment = NSTextAlignmentCenter;
        _hintsLabel.numberOfLines = 0;
        _hintsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _hintsLabel.font = [UIFont systemFontOfSize:16.0];
        _hintsLabel.backgroundColor = [UIColor clearColor];
    }
    return _hintsLabel;
}

- (void)setOwner:(UIScrollView *)owner
{
    _owner = owner;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [_owner class];
        
        SEL originalSelector = @selector(willMoveToSuperview:);
        SEL swizzledSelector = @selector(sf_willMoveToSuperview:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)setOrignInset:(UIEdgeInsets)orignInset
{
    if (_orignInset.left < 10000000.0) {
        return;
    }
    _orignInset = orignInset;
    if (_refreshControl) {
        
        CGRect frame = _refreshControl.frame;
        if (_refreshPosition == SFPullRefreshPositionTop) {
            
            frame.origin.y = -_refreshControl.frame.size.height;
        } else {
            frame.origin.y = [self ownerContentHeight];
        }
        _refreshControl.frame = frame;
        if (self.autoLoading) { //自动刷新
            [self refreshAnimated:YES];
        }
    }
    if (_loadMoreControl) {
        
        CGRect frame = self.loadMoreControl.frame;
        if (_loadMorePosition == SFPullRefreshPositionTop) {
            
            frame.origin.y = -self.loadMoreControl.frame.size.height;
        }
        else
        {
            frame.origin.y = self.owner.frame.size.height;
        }
        self.loadMoreControl.frame = frame;
    }
}

#pragma mark private method
- (CGFloat)ownerContentHeight {
    CGFloat height = self.owner.contentSize.height;
    if (height+self.orignInset.bottom+self.orignInset.top < self.owner.frame.size.height) {
        height = self.owner.frame.size.height - self.orignInset.bottom - self.orignInset.top;
    }
    return height;
}

- (NSInteger)totalItems
{
    NSInteger totalItems = 0;
    if ([self.owner isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.owner;
        for (NSInteger section = 0; section<tableView.numberOfSections; section++) {
            totalItems += [tableView numberOfRowsInSection:section];
        }
    } else if ([self.owner isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.owner;
        
        for (NSInteger section = 0; section<collectionView.numberOfSections; section++) {
            totalItems += [collectionView numberOfItemsInSection:section];
        }
    }
    return totalItems;
}

- (void)beginRefresh {
    self.isRefreshing = YES;
    self.refreshState = SFPullRefreshStateRefreshing;
    self.loadMoreState = SFPullRefreshStateNormal;
    if ([self.refreshControl respondsToSelector:@selector(beginRefreshing)]) {
        [self.refreshControl beginRefreshing];
    }
    
    if (self.refreshHandler) {
        self.page = 0;
        self.preHeight = 0;
        self.refreshHandler();
    }
}

- (void)beginLoadMore {
    self.loadMoreState = SFPullRefreshStateLoading;
    
    if ([self.loadMoreControl respondsToSelector:@selector(beginLoading)]) {
        [self.loadMoreControl beginLoading];
    }
    
    if (self.loadMoreHandler)
    {
        if ([self.owner respondsToSelector:@selector(numberOfSections)]) {
            
        }
        self.loadMoreHandler();
    }
}

#pragma mark public method
- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void (^)(void))refreshHandler atPosition:(SFPullRefreshPosition)position
{
    if (self.refreshControl) {
        [self.refreshControl removeFromSuperview];
    }
    self.refreshControl = refreshControl;
    self.refreshHandler = refreshHandler;
    [self.owner addSubview:self.refreshControl];
    
    if (self.loadMoreControl && self.loadMorePosition == position) {
        NSLog(@"error: can't set refreshControl at same position with loadMoreControl");
        position = -position;
    }
    self.refreshPosition = position;
}

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void (^)(void))loadMoreHandler atPosition:(SFPullRefreshPosition)position
{
    if (self.loadMoreControl) {
        [self.loadMoreControl removeFromSuperview];
    }
    self.loadMoreControl = loadMoreControl;
    [self.owner addSubview:self.loadMoreControl];
    self.loadMoreHandler = loadMoreHandler;
    
    if (self.refreshControl && self.refreshPosition == position) {
        NSLog(@"error: can't set loadMoreControl at the same position with refreshControl");
        position = -position;
    }
    self.loadMorePosition = position;
}

- (void)finishLoading
{
    if ([self.owner respondsToSelector:@selector(reloadData)]) {
        [self.owner performSelector:@selector(reloadData)];
    }
    if (_hintsLabel) {
        [_hintsView removeFromSuperview];
    }
    if (self.loadMoreControl) {
        if ([self.loadMoreControl respondsToSelector:@selector(endLoading)]) {
            [self.loadMoreControl endLoading];
        }
        
        if (self.loadMoreState == SFPullRefreshStateLoading) {
            self.loadMoreState = SFPullRefreshStateNormal;
        }
    }
    if (self.refreshControl) {
        if ([self.refreshControl respondsToSelector:@selector(endRefreshing)]) {
            [self.refreshControl endRefreshing];
        }
        self.refreshState = SFPullRefreshStateNormal;
        self.isRefreshing = NO;
    }
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.owner.contentInset = self.orignInset;
    } completion:nil];
}

- (void)refreshAnimated:(BOOL)animated
{
    if (self.refreshControl) { //自动刷新
        CGFloat animateTime = 0.0;
        if (animated) {
            animateTime = 0.25;
        }
        if (self.refreshPosition == SFPullRefreshPositionTop) {
            
            [UIView animateWithDuration:animateTime animations:^{
                [self.owner setContentOffset:CGPointMake(0, -self.orignInset.top-self.refreshControl.frame.size.height) animated:NO];
            } completion:^(BOOL finished) {
                [self tableViewDidEndDragging];
            }];
        } else {
            CGFloat contentHeight = [self ownerContentHeight];
            
            [UIView animateWithDuration:animateTime animations:^{
                [self.owner setContentOffset:CGPointMake(0, contentHeight+self.orignInset.bottom-self.owner.frame.size.height+self.refreshControl.frame.size.height) animated:NO];
            } completion:^(BOOL finished) {
                [self tableViewDidEndDragging];
            }];
        }
    }
}

- (void)loadMoreAnimated:(BOOL)animated
{
    if (self.loadMoreControl) {
        CGFloat animateTime = 0.0;
        if (animated) {
            animateTime = 0.25;
        }
        if (self.loadMorePosition == SFPullRefreshPositionBottom) {
            
            CGFloat contentHeight = [self ownerContentHeight];
            [UIView animateWithDuration:animateTime animations:^{
                [self.owner setContentOffset:CGPointMake(0, contentHeight+self.orignInset.bottom-self.owner.frame.size.height+self.loadMoreControl.frame.size.height) animated:NO];
            } completion:^(BOOL finished) {
                [self tableViewDidEndDragging];
            }];
        } else {
            [UIView animateWithDuration:animateTime animations:^{
                [self.owner setContentOffset:CGPointMake(0, -self.orignInset.top-self.loadMoreControl.frame.size.height) animated:NO];
            } completion:^(BOOL finished) {
                [self tableViewDidEndDragging];
            }];
        }
    }

}

- (void)reachEndWithText:(NSString *)text
{
    if (self.loadMoreControl) {
        if (!text) {
            text = @"没有了";
        }
        if ([self.loadMoreControl respondsToSelector:@selector(reachEndWithText:)]) {
            [self.loadMoreControl reachEndWithText:text];
        }
        
        self.loadMoreState = SFPullRefreshStateReachEnd;
    }
}

- (void)showHints:(NSString *)hints {
    self.hintsLabel.text = hints;
    [self showHintsView:self.hintsLabel];
}

- (void)showHintsView:(UIView *)hintsView {
    self.hintsView = hintsView;
    [self.owner addSubview:self.hintsView];
}

- (void)setControlColor:(UIColor *)controlColor
{
    if (self.refreshControl && [self.refreshControl respondsToSelector:@selector(setControlColor:)]) {
        [self.refreshControl setControlColor:controlColor];
    }
    if (self.loadMoreControl && [self.loadMoreControl respondsToSelector:@selector(setControlColor:)]) {
        [self.loadMoreControl setControlColor:controlColor];
    }
}

- (void)addObservers {
    [self.owner addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.owner addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.owner.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.owner removeObserver:self forKeyPath:@"contentSize"];
    [self.owner removeObserver:self forKeyPath:@"contentOffset"];
    [self.owner.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
}

#define mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == self.owner) {
        if ([keyPath isEqualToString:@"contentSize"] && self.loadMoreControl) {
            
            CGFloat preContentHeight = [[change objectForKey:@"old"] CGSizeValue].height;
            CGFloat curContentHeight = [[change objectForKey:@"new"] CGSizeValue].height;
            
            if (preContentHeight == curContentHeight) {
                return;
            }
            if (curContentHeight>self.preHeight) {
                self.page++;
                self.preHeight = curContentHeight;
            }
            if (self.loadMoreControl) { //底部加载更多，则需要每次加载完更新位置
                
                if (self.loadMorePosition == SFPullRefreshPositionBottom) {
                    
                    CGRect frame = self.loadMoreControl.frame;
                    frame.origin.y = [self ownerContentHeight];
                    self.loadMoreControl.frame = frame;

                } else {
                    if (curContentHeight-preContentHeight>0) {
                        CGPoint offset = self.owner.contentOffset;
                        if (preContentHeight == 0) {
                            CGFloat contentHeight = [self ownerContentHeight];
                            offset.y = contentHeight+self.orignInset.bottom-self.owner.frame.size.height;
                        }
                        else if (preContentHeight > 0)
                        {
                            offset.y += curContentHeight-preContentHeight;
                        }
                        self.owner.contentOffset = offset;
                    }
                }
                
            }
            if (self.refreshControl && self.refreshPosition == SFPullRefreshPositionBottom) {
                CGRect frame = self.refreshControl.frame;
                frame.origin.y = [self ownerContentHeight];
                self.refreshControl.frame = frame;
            }
        } else if ([keyPath isEqualToString:@"contentOffset"]) {
            
            [self tableViewDidScroll];
        }
    } else if (object == self.owner.panGestureRecognizer) {
        if ([keyPath isEqualToString:@"state"] && self.owner.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            
            [self tableViewDidEndDragging];
        }
    }
}

- (void)tableViewDidScroll {

    if (self.refreshControl && self.refreshState != SFPullRefreshStateRefreshing) {
        
        if (self.refreshPosition == SFPullRefreshPositionTop) {
            
            CGFloat yMargin = self.owner.contentOffset.y + self.orignInset.top;
            if (yMargin < 0 && yMargin > -self.refreshControl.frame.size.height){ //refreshControl partly appeared
                self.refreshState = SFPullRefreshStatePullToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(yMargin)/self.refreshControl.frame.size.height];
                }
                
            } else if (yMargin <= -self.refreshControl.frame.size.height && self.refreshState != SFPullRefreshStateReleaseToRefresh) {   //refreshControl totally appeard
                
                self.refreshState = SFPullRefreshStateReleaseToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(yMargin)/self.refreshControl.frame.size.height];
                }
            }
        } else {
            
            CGFloat contentHeight = [self ownerContentHeight];
            CGFloat yMargin = self.owner.contentOffset.y + self.owner.frame.size.height - contentHeight - self.orignInset.bottom;
            if (yMargin > 0 && yMargin<self.refreshControl.frame.size.height) { //refreshControl partly appeard
                
                self.refreshState = SFPullRefreshStatePullToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(yMargin)/self.refreshControl.frame.size.height];
                }
            } else if (yMargin >= self.refreshControl.frame.size.height && self.refreshState != SFPullRefreshStateReleaseToRefresh) {   //refreshControl totally appeard
                
                self.refreshState = SFPullRefreshStateReleaseToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(yMargin)/self.refreshControl.frame.size.height];
                }
            }
        }
    }
    
    if (self.loadMoreControl && self.loadMoreState == SFPullRefreshStateNormal) {
        
        if (self.loadMorePosition == SFPullRefreshPositionTop) {
            CGFloat yMargin = self.owner.contentOffset.y+self.orignInset.top;
            if (yMargin < 0 && self.loadMoreState != SFPullRefreshStateLoading) {
                
                [self beginLoadMore];
                [UIView animateWithDuration:0.1 animations:^{
                    self.owner.contentInset = UIEdgeInsetsMake(self.loadMoreControl.frame.size.height+self.orignInset.top, self.orignInset.right, self.orignInset.bottom, self.orignInset.left);
                }];
            }
        } else {
            
            CGFloat contentHeight = [self ownerContentHeight];
            CGFloat yMargin = self.owner.contentOffset.y + self.owner.frame.size.height - contentHeight - self.orignInset.bottom;
            
            if ( yMargin > 0 && self.loadMoreState != SFPullRefreshStateLoading) {  //footer will appeared
                
                [self beginLoadMore];
                
                [UIView animateWithDuration:0.1 animations:^{
                    self.owner.contentInset = UIEdgeInsetsMake(self.orignInset.top, self.orignInset.right, self.loadMoreControl.frame.size.height+self.orignInset.bottom, self.orignInset.left);
                }];
            }
        }
    }
}

- (void)tableViewDidEndDragging
{
    if (self.refreshControl && self.refreshState == SFPullRefreshStateReleaseToRefresh) {
        
        [self beginRefresh];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            if (self.refreshPosition == SFPullRefreshPositionTop) {
                UIEdgeInsets inset = self.owner.contentInset;
                inset.top = self.refreshControl.frame.size.height+self.orignInset.top;
                self.owner.contentInset = inset;
            } else {
                UIEdgeInsets inset = self.owner.contentInset;
                //当内容太小时，设置insetbottom会导致下降，原因未知，当显示hintsView时还是有点问题
                if (self.owner.contentSize.height+self.orignInset.top+self.orignInset.bottom>self.owner.frame.size.height) {
                    inset.bottom = self.refreshControl.frame.size.height+self.orignInset.bottom;
                }
                self.owner.contentInset = inset;
            }
        } completion:nil];
    }
}

@end
