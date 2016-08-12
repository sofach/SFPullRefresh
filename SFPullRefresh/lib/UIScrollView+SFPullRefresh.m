//
//  UIScrollView+SFPullRefresh.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//
#import <objc/runtime.h>

#import "UIScrollView+SFPullRefresh.h"

@interface SFPullRefreshController : NSObject

@property (weak, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL autoRefresh;

- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void(^)(void))refreshHandler;

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void(^)(void))loadMoreHandler;

- (void)refreshAnimated:(BOOL)animated;

- (void)loadMoreAnimated:(BOOL)animated;

- (void)setScrollViewOrignInset:(UIEdgeInsets)orignInset;

- (void)finishLoading;

- (void)reachEndWithText:(NSString *)text;
- (void)reachEndWithView:(UIView *)view;

- (void)showHintsView:(UIView *)hintsView;

- (void)restartAnimation;

- (void)setControlColor:(UIColor *)controlColor;

- (void)addObservers;

- (void)removeObservers;

@end

@interface UIScrollView ()

@property (strong, nonatomic) SFPullRefreshController *sf_pullRefreshController;

@end

@implementation UIScrollView (SFPullRefresh)

#pragma mark getter setter
- (SFPullRefreshController *)sf_pullRefreshController {
    return objc_getAssociatedObject(self, @selector(sf_pullRefreshController));
}

- (void)setSf_pullRefreshController:(SFPullRefreshController *)sf_pullRefreshController {
    [self willChangeValueForKey:@"sf_pullRefreshController"]; // KVO
    objc_setAssociatedObject(self, @selector(sf_pullRefreshController), sf_pullRefreshController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"sf_pullRefreshController"]; // KVO
}

- (SFPullRefreshController *)sf_getPullRefreshController {
    if (!self.sf_pullRefreshController) {
        self.sf_pullRefreshController = [[SFPullRefreshController alloc] init];
        self.sf_pullRefreshController.scrollView = self;
        if (self.superview) { //有时候scrollview movetosuperview调用过早
            [self.sf_pullRefreshController addObservers];
            [self.sf_getPullRefreshController setScrollViewOrignInset:self.contentInset];
        }
    }
    return self.sf_pullRefreshController;
}

#pragma mark - public method
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler {
    [self sf_addRefreshHandler:refreshHandler customRefreshControl:nil];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl {
    
    if (!customRefreshControl) {
        customRefreshControl = [[SFRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    }
    
    [[self sf_getPullRefreshController] setRefreshControl:customRefreshControl withRefreshHandler:refreshHandler];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler {
    [self sf_addLoadMoreHandler:loadMoreHandler customLoadMoreControl:nil];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl {
    
    if (!customLoadMoreControl) {
        customLoadMoreControl = [[SFLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
    }
    [[self sf_getPullRefreshController] setLoadMoreControl:customLoadMoreControl withLoadMoreHandler:loadMoreHandler];
}

- (BOOL)sf_isRefreshing {
    return [self sf_getPullRefreshController].isRefreshing;
}

- (void)sf_autoRefresh:(BOOL)autoRefresh {
    [self sf_getPullRefreshController].autoRefresh = autoRefresh;
}

- (void)sf_finishLoading {
    [[self sf_getPullRefreshController] finishLoading];
}

- (void)sf_refreshAnimated:(BOOL)animated {
    [[self sf_getPullRefreshController] refreshAnimated:animated];
}

- (void)sf_loadMoreAnimated:(BOOL)animated {
    [[self sf_getPullRefreshController] loadMoreAnimated:animated];
}

- (void)sf_reachEndWithText:(NSString *)text {
    [[self sf_getPullRefreshController] reachEndWithText:text];
}

- (void)sf_reachEndWithView:(UIView *)view {
    [[self sf_getPullRefreshController] reachEndWithView:view];
}

- (void)sf_showHintsView:(UIView *)hintsView {
    [[self sf_getPullRefreshController] showHintsView:hintsView];
}

- (void)sf_setControlColor:(UIColor *)controlColor {
    [[self sf_getPullRefreshController] setControlColor:controlColor];
}

- (void)sf_willMoveToSuperview:(UIView *)newSuperView {
    [self sf_willMoveToSuperview:newSuperView];
    
    if (self.sf_pullRefreshController) {
        if (self.superview) {
            [self.sf_pullRefreshController removeObservers];
        }
        if (newSuperView) {
            [self.sf_pullRefreshController addObservers];
            [self.sf_getPullRefreshController setScrollViewOrignInset:self.contentInset];
        }
    }
}

- (void)sf_willMoveToWindow:(UIWindow *)newWindow {
    [self sf_willMoveToWindow:newWindow];
    if (self.sf_pullRefreshController) {
        [self.sf_pullRefreshController restartAnimation];
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
@interface SFPullRefreshController ()

@property (assign, nonatomic) BOOL insetChanged;
@property (assign, nonatomic) BOOL refreshAnimated;

@property (assign, nonatomic) UIEdgeInsets orignInset;

@property (assign, nonatomic) SFPullRefreshState refreshState;
@property (assign, nonatomic) SFPullRefreshState loadMoreState;

@property (copy, nonatomic) void (^refreshHandler)(void);
@property (copy, nonatomic) void (^loadMoreHandler)(void);

@property (strong, nonatomic) UIView <SFRefreshControlDelegate> * refreshControl;
@property (strong, nonatomic) UIView <SFLoadMoreControlDelegate> * loadMoreControl;

@property (strong, nonatomic) UILabel *hintsLabel;
@property (strong, nonatomic) UIView *hintsView;
@property (strong, nonatomic) UIView *reachEndView;

@end

#define DefaultTop -100204

@implementation SFPullRefreshController

- (id)init {
    self = [super init];
    if (self) {
        _autoRefresh = YES;
        _orignInset.top = DefaultTop;
        
    }
    return self;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIScrollView class];
        [SFPullRefreshController replaceSelector:@selector(willMoveToWindow:) toSelector:@selector(sf_willMoveToWindow:) forClass:class]; //为了切换view，重启动画
        [SFPullRefreshController replaceSelector:@selector(willMoveToSuperview:) toSelector:@selector(sf_willMoveToSuperview:) forClass:class];
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

#pragma mark - getter setter
//有2个地方可以设置origininset，一个是监听scrollview的contentinset，因为navigationbar透明时，会自动修改scrollview的contentinset，所以这个时候也需要重新设置origininset。
//另一个是在movetosuperview时，movetosuperview调用的只需要修改一次，因为某些清空下，监听不到scrollview的contentinset变化
- (void)setScrollViewOrignInset:(UIEdgeInsets)orignInset {
    if (_orignInset.top == DefaultTop) {
        self.orignInset = orignInset;
    }
}

- (void)setOrignInset:(UIEdgeInsets)orignInset {
    _orignInset = orignInset;
    if (_refreshControl && !_isRefreshing) {
        if (self.autoRefresh) { //自动刷新
            [self refreshAnimated:YES];
        }
    }
}

#pragma mark private method
- (CGFloat)scrollViewContentHeight {
    CGFloat height = self.scrollView.contentSize.height;
    if (height+self.orignInset.bottom+self.orignInset.top < self.scrollView.frame.size.height) {
        height = self.scrollView.frame.size.height - self.orignInset.bottom - self.orignInset.top;
    }
    return height;
}

- (void)beginRefresh {
    self.isRefreshing = YES;
    self.refreshState = SFPullRefreshStateRefreshing;
    self.loadMoreState = SFPullRefreshStateNormal;
    if ([self.refreshControl respondsToSelector:@selector(beginRefreshing)]) {
        [self.refreshControl beginRefreshing];
    }
    
    if (self.refreshHandler) {
        self.refreshHandler();
    }
}

- (void)setScrollViewContentInset:(UIEdgeInsets)inset {
    self.insetChanged = YES;
    self.scrollView.contentInset = inset;
}

- (void)beginLoadMore {
    if (self.reachEndView && self.reachEndView.superview) {
        [self.reachEndView removeFromSuperview];
    }
    self.loadMoreState = SFPullRefreshStateLoading;
    if ([self.loadMoreControl respondsToSelector:@selector(beginLoading)]) {
        [self.loadMoreControl beginLoading];
    }
    
    if (self.loadMoreHandler) {
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
- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void (^)(void))refreshHandler {
    
    if (self.refreshControl) {
        [self.refreshControl removeFromSuperview];
    }
    self.refreshControl = refreshControl;
    self.refreshHandler = refreshHandler;
    [self.scrollView addSubview:self.refreshControl];
    
    CGRect frame = _refreshControl.frame;
    frame.origin.y = -_refreshControl.frame.size.height;
    _refreshControl.frame = frame;
}

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void (^)(void))loadMoreHandler {
    if (self.loadMoreControl) {
        [self.loadMoreControl removeFromSuperview];
    }
    self.loadMoreControl = loadMoreControl;
    [self.scrollView addSubview:self.loadMoreControl];
    self.loadMoreHandler = loadMoreHandler;
    
    CGRect frame = self.loadMoreControl.frame;
    frame.origin.y = self.scrollView.frame.size.height;
    self.loadMoreControl.frame = frame;
}

- (void)finishLoading {
    if (_hintsView) {
        [_hintsView removeFromSuperview];
    }
    UIEdgeInsets insets = self.orignInset;
    if (self.loadMoreControl) {
        NSTimeInterval interval = 0.25f;
        
        if ([self.loadMoreControl respondsToSelector:@selector(endLoading)]) {
            interval = [self.loadMoreControl endLoading];
        }
        insets.bottom = self.scrollView.contentInset.bottom;
        
        [UIView animateWithDuration:interval delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self setScrollViewContentInset:insets];
        } completion:^(BOOL completion){ //collectionview在设置contentinsets动画的同时reloaddata会有点问题
            if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
                [self.scrollView performSelector:@selector(reloadData)];
            }
            if (self.loadMoreState == SFPullRefreshStateLoading) { //因为有可能先调用reachend
                self.loadMoreState = SFPullRefreshStateNormal;
            }
        }];
    }
    if (self.refreshControl && self.refreshState == SFPullRefreshStateRefreshing) {
        
        NSTimeInterval interval = .25;
        if ([self.refreshControl respondsToSelector:@selector(endRefreshing)]) {
            interval = [self.refreshControl endRefreshing];
        }
        
        if (![self.scrollView isKindOfClass:[UICollectionView class]]) {
            if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
                [self.scrollView performSelector:@selector(reloadData)];
            }
        }
        
        if (_refreshAnimated) {
            [UIView animateWithDuration:interval delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self setScrollViewContentInset:insets];
            } completion:^(BOOL completion){ //collectionview在设置contentinsets动画的同时reloaddata会有点问题
                if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
                    if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
                        [self.scrollView performSelector:@selector(reloadData)];
                    }
                }
                self.refreshState = SFPullRefreshStateNormal; //必须在结束动画时改变状态，在此之前，contentoffset有可能会改变，比如reloaddata
                self.isRefreshing = NO;
            }];
        } else {
            if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
                if ([self.scrollView respondsToSelector:@selector(reloadData)]) {
                    [self.scrollView performSelector:@selector(reloadData)];
                }
            }
            self.refreshState = SFPullRefreshStateNormal;
            self.isRefreshing = NO;
        }
    }
}

- (void)refreshAnimated:(BOOL)animated {
    if (self.refreshControl && !self.isRefreshing) { //自动刷新
        _refreshAnimated = animated;
        self.isRefreshing = YES;
        
        if (animated) {
            [UIView animateWithDuration:.25 animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, -self.orignInset.top-self.refreshControl.frame.size.height) animated:NO];
            } completion:^(BOOL finished) {
                self.refreshState = SFPullRefreshStateReleaseToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:1];
                }
                [self tableViewDidEndDragging];
            }];
        } else {
            [self beginRefresh];
        }
    }
}

- (void)loadMoreAnimated:(BOOL)animated {
    if (self.loadMoreControl) {
        CGFloat animateTime = 0.0;
        if (animated) {
            animateTime = 0.25;
        }
        CGFloat contentHeight = [self scrollViewContentHeight];
        [UIView animateWithDuration:animateTime animations:^{
            [self.scrollView setContentOffset:CGPointMake(0, contentHeight+self.orignInset.bottom-self.scrollView.frame.size.height+self.loadMoreControl.frame.size.height) animated:NO];
        } completion:^(BOOL finished) {
            [self tableViewDidEndDragging];
        }];
    }
}

- (void)reachEndWithText:(NSString *)text {
    if (self.loadMoreControl) {
        if (!text) {
            text = @"没有了";
        }
        if ([self.loadMoreControl respondsToSelector:@selector(reachEndWithText:)]) {
            [self.loadMoreControl reachEndWithText:text];
        }
        
        [UIView animateWithDuration:.25 animations:^{
            [self setScrollViewContentInset:self.orignInset];
        }];
        self.loadMoreState = SFPullRefreshStateReachEnd;
    }
}

- (void)reachEndWithView:(UIView *)view {
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
            [self setScrollViewContentInset:self.orignInset];
        }];
        self.loadMoreState = SFPullRefreshStateReachEnd;
    }
}

- (void)showHintsView:(UIView *)hintsView {
    if (self.hintsView && self.hintsView.superview) {
        [self.hintsView removeFromSuperview];
    }
    self.hintsView = hintsView;
    [self.scrollView addSubview:self.hintsView];
}

- (void)setControlColor:(UIColor *)controlColor {
    if (self.refreshControl && [self.refreshControl respondsToSelector:@selector(setControlColor:)]) {
        [self.refreshControl setControlColor:controlColor];
    }
    if (self.loadMoreControl && [self.loadMoreControl respondsToSelector:@selector(setControlColor:)]) {
        [self.loadMoreControl setControlColor:controlColor];
    }
}

- (void)addObservers {
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers {
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
}

#define mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.scrollView) {
        if ([keyPath isEqualToString:@"contentSize"] && self.loadMoreControl) {
            
            if (self.loadMoreControl) { //底部加载更多，则需要每次加载完更新位置
                
                CGRect frame = self.loadMoreControl.frame;
                frame.origin.y = [self scrollViewContentHeight];
                self.loadMoreControl.frame = frame;
            }
            
        } else if ([keyPath isEqualToString:@"contentOffset"]) {
            [self tableViewDidScroll];
        } else if ([keyPath isEqualToString:@"contentInset"]) {
            if (!self.insetChanged) { //仅仅是willMoveToView时设置originInset不够。手动修改的inset，不记录
                self.orignInset = self.scrollView.contentInset;
            }
        }
    } else if (object == self.scrollView.panGestureRecognizer) {
        if ([keyPath isEqualToString:@"state"] && self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            
            [self tableViewDidEndDragging];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)tableViewDidScroll {
    
    if (self.refreshControl && self.refreshState != SFPullRefreshStateRefreshing && self.loadMoreState != SFPullRefreshStateLoading) {
        
        CGFloat yMargin = self.scrollView.contentOffset.y + self.orignInset.top;
        
        CGFloat threshold = 1.5*self.refreshControl.frame.size.height;
        if (yMargin < 0 && yMargin > -threshold){ //refreshControl partly appeared
            self.refreshState = SFPullRefreshStatePullToRefresh;
            if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                [self.refreshControl willRefreshWithProgress:fabs(yMargin)/threshold];
            }
            
        } else if (yMargin <= -threshold) {   //refreshControl totally appeard
            self.refreshState = SFPullRefreshStateReleaseToRefresh;
            if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                [self.refreshControl willRefreshWithProgress:fabs(yMargin)/threshold];
            }
        }
    }
    
    if (self.loadMoreControl && self.loadMoreState == SFPullRefreshStateNormal && self.refreshState != SFPullRefreshStateRefreshing) {
        
        CGFloat contentHeight = [self scrollViewContentHeight];
        CGFloat yMargin = self.scrollView.contentOffset.y + self.scrollView.frame.size.height - contentHeight - self.orignInset.bottom;
        
        if ( yMargin > 0) {  //footer will appeared
            
            [self beginLoadMore];
            
            [UIView animateWithDuration:.1 animations:^{
                UIEdgeInsets inset = UIEdgeInsetsMake(self.orignInset.top, self.orignInset.right, self.loadMoreControl.frame.size.height+self.orignInset.bottom, self.orignInset.left);
                [self setScrollViewContentInset:inset];
            }];
        }
    }
}

- (void)tableViewDidEndDragging {
    if (self.refreshControl && self.refreshState == SFPullRefreshStateReleaseToRefresh && self.loadMoreState != SFPullRefreshStateLoading) {
        
        self.isRefreshing = YES;
        self.refreshState = SFPullRefreshStateRefreshing;
        self.loadMoreState = SFPullRefreshStateNormal;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.top = self.refreshControl.frame.size.height+self.orignInset.top;
            [self setScrollViewContentInset:inset];
        } completion:^(BOOL completed) {
            [self beginRefresh];
        }];
        
    }
}

@end
