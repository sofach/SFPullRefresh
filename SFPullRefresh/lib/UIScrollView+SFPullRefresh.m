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
@property (assign, nonatomic) BOOL autoRefresh;
@property (assign, nonatomic) UIEdgeInsets orignInset;

- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void(^)(void))refreshHandler atPosition:(SFPullRefreshPosition)position;

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void(^)(void))loadMoreHandler atPosition:(SFPullRefreshPosition)position;

- (void)refreshAnimated:(BOOL)animated;

- (void)loadMoreAnimated:(BOOL)animated;

- (void)finishLoading;

- (void)reachEndWithText:(NSString *)text;
- (void)reachEndWithView:(UIView *)view;

- (void)showHints:(NSString *)hints;
- (void)showHintsView:(UIView *)hintsView;

- (void)restartAnimation;

- (void)setControlColor:(UIColor *)controlColor;

- (void)addObservers;

- (void)removeObservers;

@end

@interface UIScrollView ()

@property (strong, nonatomic) SFPullRefreshContext *sf_pullRefreshContext;

@end

@implementation UIScrollView (SFPullRefresh)

#pragma mark getter setter
- (SFPullRefreshContext *)sf_pullRefreshContext {
    return objc_getAssociatedObject(self, @selector(sf_pullRefreshContext));
}

- (void)setSf_pullRefreshContext:(SFPullRefreshContext *)sf_pullRefreshContext {
    [self willChangeValueForKey:@"sf_pullRefreshContext"]; // KVO
    objc_setAssociatedObject(self, @selector(sf_pullRefreshContext), sf_pullRefreshContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"sf_pullRefreshContext"]; // KVO
}

#pragma mark - public method
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler {
    [self sf_addRefreshHandler:refreshHandler position:SFPullRefreshPositionTop];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position {
    [self sf_addRefreshHandler:refreshHandler position:position customRefreshControl:nil];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl {

    if (!self.sf_pullRefreshContext) {
        self.sf_pullRefreshContext = [[SFPullRefreshContext alloc] init];
        self.sf_pullRefreshContext.owner = self;
    }
    
    if (!customRefreshControl) {
        customRefreshControl = [[SFRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    }
    
    [self.sf_pullRefreshContext setRefreshControl:customRefreshControl withRefreshHandler:refreshHandler atPosition:position];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler {
    [self sf_addLoadMoreHandler:loadMoreHandler position:SFPullRefreshPositionBottom];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position {
    [self sf_addLoadMoreHandler:loadMoreHandler position:position customLoadMoreControl:nil];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl {
    if (!self.sf_pullRefreshContext) {
        self.sf_pullRefreshContext = [[SFPullRefreshContext alloc] init];
        self.sf_pullRefreshContext.owner = self;
    }

    if (!customLoadMoreControl) {
        customLoadMoreControl = [[SFLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    }
    [self.sf_pullRefreshContext setLoadMoreControl:customLoadMoreControl withLoadMoreHandler:loadMoreHandler atPosition:position];
}

- (BOOL)sf_isRefreshing {
    return self.sf_pullRefreshContext.isRefreshing;
}

- (NSUInteger)sf_page {
    return self.sf_pullRefreshContext.page;
}

- (void)sf_autoRefresh:(BOOL)autoRefresh {
    if (!self.sf_pullRefreshContext) {
        self.sf_pullRefreshContext = [[SFPullRefreshContext alloc] init];
        self.sf_pullRefreshContext.owner = self;
    }
    self.sf_pullRefreshContext.autoRefresh = autoRefresh;
}

- (void)sf_finishLoading {
    [self.sf_pullRefreshContext finishLoading];
}

- (void)sf_refreshAnimated:(BOOL)animated {
    [self.sf_pullRefreshContext refreshAnimated:animated];
}

- (void)sf_loadMoreAnimated:(BOOL)animated {
    [self.sf_pullRefreshContext loadMoreAnimated:animated];
}

- (void)sf_reachEndWithText:(NSString *)text {
    [self.sf_pullRefreshContext reachEndWithText:text];
}

- (void)sf_reachEndWithView:(UIView *)view {
    [self.sf_pullRefreshContext reachEndWithView:view];
}

- (void)sf_showHints:(NSString *)hints {
    [self.sf_pullRefreshContext showHints:hints];
}

- (void)sf_showHintsView:(UIView *)hintsView {
    [self.sf_pullRefreshContext showHintsView:hintsView];
}

- (void)sf_setControlColor:(UIColor *)controlColor {
    [self.sf_pullRefreshContext setControlColor:controlColor];
}

- (void)sf_willMoveToSuperview:(UIView *)newSuperView {
    [self sf_willMoveToSuperview:newSuperView];
    
    if (self.sf_pullRefreshContext) {
        
        if (self.superview) {
            [self.sf_pullRefreshContext removeObservers];
        }

        if (newSuperView) {
            [self.sf_pullRefreshContext addObservers];
            self.sf_pullRefreshContext.orignInset = self.contentInset;
        }
    }
}

- (void)sf_willMoveToWindow:(UIWindow *)newWindow {
    [self sf_willMoveToWindow:newWindow];
    if (self.sf_pullRefreshContext) {
        [self.sf_pullRefreshContext restartAnimation];
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
@property (assign, nonatomic) BOOL insetChanged;
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
@property (strong, nonatomic) UIView *reachEndView;

@end

@implementation SFPullRefreshContext

- (id)init
{
    self = [super init];
    if (self) {
        _page = 0;
        _preHeight = 0;
        _autoRefresh = YES;
        _orignInset.top = -1;
        _refreshPosition = SFPullRefreshPositionTop;
        _loadMorePosition = SFPullRefreshPositionBottom;
    }
    return self;
}



#pragma mark - getter setter
- (UILabel *)hintsLabel {
    if (!_hintsLabel) {
        _hintsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _owner.frame.size.width, _owner.frame.size.height/2-_orignInset.top-_orignInset.bottom)];
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
        Class class = [UIScrollView class];
        [SFPullRefreshContext replaceSelector:@selector(willMoveToWindow:) toSelector:@selector(sf_willMoveToWindow:) forClass:class]; //为了切换view，重启动画
        [SFPullRefreshContext replaceSelector:@selector(willMoveToSuperview:) toSelector:@selector(sf_willMoveToSuperview:) forClass:class];
    });
}

+ (void)replaceSelector:(SEL)originalSelector toSelector:(SEL)swizzledSelector forClass:(Class)cls {
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    
    BOOL success = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (success) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)setOrignInset:(UIEdgeInsets)orignInset
{
    //这里对UITableViewController支持的不大好，不知道什么原因，当在外部设置tableView.contentInsets时，UITableViewController直接加上了透明的navigationBar的高度，导致下移多下移了64
//    if (_orignInset.top > 0.0) {
//        return;
//    }
    _orignInset = orignInset;
    if (_refreshControl) {
        
        CGRect frame = _refreshControl.frame;
        if (_refreshPosition == SFPullRefreshPositionTop) {
            
            frame.origin.y = -_refreshControl.frame.size.height;
        } else {
            frame.origin.y = [self ownerContentHeight];
        }
        _refreshControl.frame = frame;
        if (self.autoRefresh) { //自动刷新
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

//- (NSInteger)totalItems
//{
//    NSInteger totalItems = 0;
//    if ([self.owner isKindOfClass:[UITableView class]]) {
//        UITableView *tableView = (UITableView *)self.owner;
//        for (NSInteger section = 0; section<tableView.numberOfSections; section++) {
//            totalItems += [tableView numberOfRowsInSection:section];
//        }
//    } else if ([self.owner isKindOfClass:[UICollectionView class]]) {
//        UICollectionView *collectionView = (UICollectionView *)self.owner;
//        
//        for (NSInteger section = 0; section<collectionView.numberOfSections; section++) {
//            totalItems += [collectionView numberOfItemsInSection:section];
//        }
//    }
//    return totalItems;
//}

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

- (void)setOwnerInset:(UIEdgeInsets)inset {
    self.insetChanged = YES;
    self.owner.contentInset = inset;
}

- (void)beginLoadMore {
    if (self.reachEndView && self.reachEndView.superview) {
        [self.reachEndView removeFromSuperview];
    }
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

- (void)restartAnimation {
    if (self.loadMoreControl && self.loadMoreState == SFPullRefreshStateLoading) {
        [self.loadMoreControl beginLoading];
    }
    if (self.refreshControl && self.refreshState == SFPullRefreshStateRefreshing) {
        [self.refreshControl beginRefreshing];
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
    if (_hintsView) {
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
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        UIEdgeInsets insets = self.orignInset;
        insets.bottom = self.owner.contentInset.bottom;
        [self setOwnerInset:insets];
    } completion:^(BOOL com){
        if ([self.owner respondsToSelector:@selector(reloadData)]) {
            [self.owner performSelector:@selector(reloadData)];
        }
    }];
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
        
        [UIView animateWithDuration:.25 animations:^{
            [self setOwnerInset:self.orignInset];
        }];
        self.loadMoreState = SFPullRefreshStateReachEnd;
    }
}

- (void)reachEndWithView:(UIView *)view
{
    if (self.loadMoreControl) {
        if (self.reachEndView && self.reachEndView.superview) {
            [self.reachEndView removeFromSuperview];
        }
        self.reachEndView = view;
        [self.loadMoreControl addSubview:self.reachEndView];
        [self.reachEndView setFrame:self.loadMoreControl.bounds];
        if ([self.loadMoreControl respondsToSelector:@selector(reachEndWithText:)]) {
            [self.loadMoreControl reachEndWithText:nil];
        }
        
        [UIView animateWithDuration:.25 animations:^{
            [self setOwnerInset:self.orignInset];
        }];
        self.loadMoreState = SFPullRefreshStateReachEnd;
    }
}

- (void)showHints:(NSString *)hints {
    self.hintsLabel.text = hints;
    [self showHintsView:self.hintsLabel];
}

- (void)showHintsView:(UIView *)hintsView {
    if (self.hintsView && self.hintsView.superview) {
        [self.hintsView removeFromSuperview];
    }
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
    [self.owner addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];

    [self.owner addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.owner.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.owner removeObserver:self forKeyPath:@"contentSize"];
    [self.owner removeObserver:self forKeyPath:@"contentInset"];
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
        } else if ([keyPath isEqualToString:@"contentInset"]) {
            if (!self.insetChanged) { //仅仅是willMoveToView时设置originInset不够。手动修改的inset，不记录
                self.orignInset = self.owner.contentInset;
            }
        }
    } else if (object == self.owner.panGestureRecognizer) {
        if ([keyPath isEqualToString:@"state"] && self.owner.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            
            [self tableViewDidEndDragging];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
            if (yMargin < -5) {
                
                [self beginLoadMore];
                [UIView animateWithDuration:0.1 animations:^{
                    [self setOwnerInset:UIEdgeInsetsMake(self.loadMoreControl.frame.size.height+self.orignInset.top, self.orignInset.right, self.orignInset.bottom, self.orignInset.left)];
                }];
            }
        } else {
            
            CGFloat contentHeight = [self ownerContentHeight];
            CGFloat yMargin = self.owner.contentOffset.y + self.owner.frame.size.height - contentHeight - self.orignInset.bottom;
            
            if ( yMargin > 0) {  //footer will appeared
                
                [self beginLoadMore];
                
                [UIView animateWithDuration:0.1 animations:^{
                    [self setOwnerInset:UIEdgeInsetsMake(self.orignInset.top, self.orignInset.right, self.loadMoreControl.frame.size.height+self.orignInset.bottom, self.orignInset.left)];
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
                [self setOwnerInset:inset];
            } else {
                UIEdgeInsets inset = self.owner.contentInset;
                //当内容太小时，设置insetbottom会导致下降，原因未知，当显示hintsView时还是有点问题
                if (self.owner.contentSize.height+self.orignInset.top+self.orignInset.bottom>self.owner.frame.size.height) {
                    inset.bottom = self.refreshControl.frame.size.height+self.orignInset.bottom;
                }
                [self setOwnerInset:inset];
            }
        } completion:nil];
    }
}

@end
