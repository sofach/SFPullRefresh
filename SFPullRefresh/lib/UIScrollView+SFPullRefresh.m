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
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL autoLoading;

- (void)setRefreshControl:(UIView<SFRefreshControlDelegate> *)refreshControl withRefreshHandler:(void(^)(void))refreshHandler atPosition:(SFPullRefreshPosition)position;

- (void)setLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)loadMoreControl withLoadMoreHandler:(void(^)(void))loadMoreHandler atPosition:(SFPullRefreshPosition)position;

- (void)refreshAnimated:(BOOL)animated;

- (void)loadMoreAnimated:(BOOL)animated;

- (void)reachEndWithText:(NSString *)text;

- (void)finishLoading;

- (void)setControlColor:(UIColor *)controlColor;

- (void)removeObservers;

@end

@interface UIScrollView ()


@end

@implementation UIScrollView (SFPullRefresh)
@dynamic context;

#pragma mark getter setter
- (SFPullRefreshContext *)context
{
    return objc_getAssociatedObject(self, @selector(context));
}

- (void)setContext:(SFPullRefreshContext *)context
{
    objc_setAssociatedObject(self, @selector(context), context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - public method
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler
{
    [self sf_addRefreshHandler:refreshHandler customRefreshControl:nil];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl
{
    [self sf_addRefreshHandler:refreshHandler customRefreshControl:customRefreshControl position:SFPullRefreshPositionTop];
}

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl position:(SFPullRefreshPosition)position
{
    if (![self respondsToSelector:@selector(backgroundView)]) {
        return;
    }
    
    if (!self.context) {
        self.context = [[SFPullRefreshContext alloc] init];
        self.context.owner = self;
    }
    
    if (!customRefreshControl) {
        customRefreshControl = [[SFRefreshControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    }
    
    [self.context setRefreshControl:customRefreshControl withRefreshHandler:refreshHandler atPosition:position];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler
{
    [self sf_addLoadMoreHandler:loadMoreHandler customLoadMoreControl:nil];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl
{
    [self sf_addLoadMoreHandler:loadMoreHandler customLoadMoreControl:nil position:SFPullRefreshPositionBottom];
}

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl position:(SFPullRefreshPosition)position
{
    if (!self.context) {
        self.context = [[SFPullRefreshContext alloc] init];
        self.context.owner = self;
    }

    if (!customLoadMoreControl) {
        customLoadMoreControl = [[SFLoadMoreControl alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    }
    [self.context setLoadMoreControl:customLoadMoreControl withLoadMoreHandler:loadMoreHandler atPosition:position];
}

- (BOOL)sf_isRefreshing
{
    return self.context.isRefreshing;
}

- (void)sf_finishLoading
{
    [self.context finishLoading];
}

- (void)sf_refreshAnimated:(BOOL)animated
{
    [self.context refreshAnimated:animated];
}

- (void)sf_loadMoreAnimated:(BOOL)animated
{
    [self.context loadMoreAnimated:animated];
}

- (void)sf_reachEndWithText:(NSString *)text
{
    [self.context reachEndWithText:text];
}

- (void)sf_setControlColor:(UIColor *)controlColor
{
    [self.context setControlColor:controlColor];
}

- (void)sf_willMoveToSuperview:(UIView *)newSuperView
{
    [self sf_willMoveToSuperview:newSuperView];
    if (self.superview && !newSuperView) {
        [self.context removeObservers];
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

@property (assign, nonatomic) CGFloat orignInsetTop;
@property (assign, nonatomic) CGFloat orignOffsetY;

@property (assign, nonatomic) CGFloat preContentHeight;

@property (strong, nonatomic) UIView *backgroundView;

@property (copy, nonatomic) void (^refreshHandler)(void);
@property (copy, nonatomic) void (^loadMoreHandler)(void);

@property (strong, nonatomic) UIView <SFRefreshControlDelegate> * refreshControl;
@property (strong, nonatomic) UIView <SFLoadMoreControlDelegate> * loadMoreControl;

@property (assign, nonatomic) SFPullRefreshState refreshState;
@property (assign, nonatomic) SFPullRefreshState loadMoreState;

@property (assign, nonatomic) SFPullRefreshPosition refreshPosition;
@property (assign, nonatomic) SFPullRefreshPosition loadMorePosition;

@end

@implementation SFPullRefreshContext

- (id)init
{
    self = [super init];
    if (self) {
        _orignInsetTop = CGFLOAT_MAX;
        _orignOffsetY = CGFLOAT_MAX;
        _preContentHeight = 0;
        _autoLoading = YES;
        _refreshPosition = SFPullRefreshPositionTop;
        _loadMorePosition = SFPullRefreshPositionBottom;
    }
    return self;
}



#pragma mark - getter setter
- (void)setOwner:(UIScrollView *)owner
{
    _owner = owner;
    if ([_owner respondsToSelector:@selector(backgroundView)]) {
        _backgroundView = [_owner performSelector:@selector(backgroundView)];
        if (!_backgroundView) {
            _backgroundView = [[UIView alloc] initWithFrame:_owner.bounds];
            [_owner performSelector:@selector(setBackgroundView:) withObject:_backgroundView];
        }
    }
    
    static dispatch_once_t once_token;
    dispatch_once(&once_token,  ^{
        SEL orignSelector = @selector(willMoveToSuperview:);
        SEL extendedSelector = @selector(sf_willMoveToSuperview:);
        Method originalMethod = class_getInstanceMethod([_owner class], orignSelector);
        Method extendedMethod = class_getInstanceMethod([_owner class], extendedSelector);
        method_exchangeImplementations(originalMethod, extendedMethod);
    });
    
    [_owner addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [_owner addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setOrignInsetTop:(CGFloat)orignInsetTop
{
    _orignInsetTop = orignInsetTop;
    if (_refreshControl && _refreshPosition == SFPullRefreshPositionTop) {
        CGRect frame = _refreshControl.frame;
        frame.origin.y = _orignInsetTop;
        _refreshControl.frame = frame;
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
    [self.backgroundView addSubview:self.refreshControl];
    
    if (self.loadMoreControl && self.loadMorePosition == position) {
        NSLog(@"error: can't set refreshControl at same position with loadMoreControl");
        position = -position;
    }
    self.refreshPosition = position;
    
    if (position == SFPullRefreshPositionTop) {
        CGRect frame = self.refreshControl.frame;
        frame.origin.y = 0;
        self.refreshControl.frame = frame;
    }
    else
    {
        CGRect frame = self.refreshControl.frame;
        frame.origin.y = self.owner.frame.size.height-self.refreshControl.frame.size.height;
        self.refreshControl.frame = frame;
    }
    
    refreshHandler = nil;
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
        NSLog(@"error: can't set loadMoreControl at same position with refreshControl");
        position = -position;
    }
    self.loadMorePosition = position;
    
    if (position == SFPullRefreshPositionTop) {
        CGRect frame = self.loadMoreControl.frame;
        frame.origin.y = -self.loadMoreControl.frame.size.height;
        self.loadMoreControl.frame = frame;
    }
    else
    {
        CGRect frame = self.loadMoreControl.frame;
        frame.origin.y = self.owner.frame.size.height;
        self.loadMoreControl.frame = frame;
    }
    
    loadMoreHandler = nil;
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

- (void)finishLoading
{
    if ([self.owner respondsToSelector:@selector(reloadData)]) {
        [self.owner performSelector:@selector(reloadData)];
    }
    
    self.preContentHeight = self.owner.contentSize.height;
    
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
        UIEdgeInsets inset = self.owner.contentInset;
        inset.top = self.orignInsetTop;
        inset.bottom = 0;
        self.owner.contentInset = inset;
    } completion:nil];
}

- (void)refreshAnimated:(BOOL)animated
{
    if (self.refreshControl) { //自动刷新
        if (self.refreshPosition == SFPullRefreshPositionTop) {
            [self.owner setContentOffset:CGPointMake(0, self.orignOffsetY-self.refreshControl.frame.size.height*5.0/4) animated:animated];
        } else {
            CGSize size = self.owner.frame.size;
            CGSize contentSize = self.owner.contentSize;
            contentSize.height += self.orignInsetTop;
            if (contentSize.height < size.height) {
                contentSize.height = size.height;
            }
            
            [self.owner setContentOffset:CGPointMake(0, _orignOffsetY+contentSize.height-size.height+self.refreshControl.frame.size.height*5.0/4) animated:animated];
        }
    }
}

- (void)loadMoreAnimated:(BOOL)animated
{
    if (self.loadMoreControl) {
        
        if (self.loadMorePosition == SFPullRefreshPositionBottom) {
            
            CGSize size = self.owner.frame.size;
            CGSize contentSize = self.owner.contentSize;
            contentSize.height += self.orignInsetTop;
            if (contentSize.height < size.height) {
                contentSize.height = size.height;
            }
            
            [self.owner setContentOffset:CGPointMake(0, _orignOffsetY+contentSize.height-size.height+self.loadMoreControl.frame.size.height) animated:animated];
            
        } else {
            [self.owner setContentOffset:CGPointMake(0, self.orignOffsetY-self.loadMoreControl.frame.size.height) animated:animated];
        }
    }

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

- (void)removeObservers
{
    [self.owner removeObserver:self forKeyPath:@"contentSize"];
    [self.owner removeObserver:self forKeyPath:@"contentOffset"];
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

            if (!self.loadMoreControl) {
                return;
            }
            
            CGRect frame = self.loadMoreControl.frame;
            if (self.loadMorePosition == SFPullRefreshPositionBottom) { //底部加载更多，则需要每次加载完更新位置
                CGSize contentSize = self.owner.contentSize;
                frame.origin.y = contentSize.height < self.owner.frame.size.height ? self.owner.frame.size.height : contentSize.height;
            }
            
            self.loadMoreControl.frame = frame;

            if (self.loadMorePosition == SFPullRefreshPositionTop) { //为了加载后不抖动
                
                if (curContentHeight-preContentHeight>0) {
                    CGPoint offset = self.owner.contentOffset;
                    if (preContentHeight == 0) {
                        offset.y = curContentHeight>self.owner.frame.size.height?(curContentHeight-self.owner.frame.size.height):0;
                    }
                    if (preContentHeight > 0)
                    {
                        offset.y += curContentHeight-preContentHeight;
                    }
                    self.owner.contentOffset = offset;
                }
            }
        } else if ([keyPath isEqualToString:@"contentOffset"]) {
            
            if (self.orignOffsetY > 1000000.0) {
                self.orignOffsetY = self.owner.contentOffset.y;
                
                //offset监听到时，inset可能还未初始化，不能将origninsetTop=self.target.contentInset.top，而初始时table的contentOffset.y值和contentInset.top值正好相反
                self.orignInsetTop = -self.owner.contentOffset.y;
                
                if (self.refreshControl && self.autoLoading) { //自动刷新
                    [self refreshAnimated:NO];
                }
//                else if (self.loadMoreControl && self.loadMorePosition == SFPullRefreshPositionTop && self.autoLoading) {
//                    [self loadMoreAnimated:NO];
//                }
            } else {
                [self tableViewDidScroll];
                if (!self.owner.isDragging) {
                    [self tableViewDidEndDragging];
                }
            }
        }
    }
}

- (void)tableViewDidScroll {
    if (self.refreshControl && self.refreshState != SFPullRefreshStateRefreshing) {
        
        CGPoint offset = self.owner.contentOffset;
        offset.y -= self.orignOffsetY;
        
        if (self.refreshPosition == SFPullRefreshPositionTop) {
            
            offset.y += self.refreshControl.frame.size.height/4;

            if (offset.y < 0 && offset.y > -self.refreshControl.frame.size.height){ //refreshControl partly appeared
                self.refreshState = SFPullRefreshStatePullToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(offset.y)/self.refreshControl.frame.size.height];
                }
                
            } else if (offset.y <= -self.refreshControl.frame.size.height) {   //refreshControl totally appeard
                self.refreshState = SFPullRefreshStateReleaseToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(offset.y)/self.refreshControl.frame.size.height];
                }
            }
        } else {
            
            CGSize size = self.owner.frame.size;
            CGSize contentSize = self.owner.contentSize;
            contentSize.height += self.orignInsetTop;
            if (contentSize.height < self.owner.frame.size.height) {
                contentSize.height = self.owner.frame.size.height;
            }
            
            offset.y += size.height;
            if (offset.y > contentSize.height && offset.y<contentSize.height+self.refreshControl.frame.size.height) { //refreshControl partly appeared
                self.refreshState = SFPullRefreshStatePullToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(offset.y-contentSize.height)/self.refreshControl.frame.size.height];
                }
                
            } else if (offset.y > contentSize.height+self.refreshControl.frame.size.height) {   //refreshControl totally appeard
                self.refreshState = SFPullRefreshStateReleaseToRefresh;
                if ([self.refreshControl respondsToSelector:@selector(willRefreshWithProgress:)]) {
                    [self.refreshControl willRefreshWithProgress:fabs(offset.y-contentSize.height)/self.refreshControl.frame.size.height];
                }
                
            }
        }
    }
    
    if (self.loadMoreControl && self.loadMoreState == SFPullRefreshStateNormal) {
        
        CGPoint offset = self.owner.contentOffset;
        offset.y -= self.orignOffsetY;
        
        CGSize size = self.owner.frame.size;
        CGSize contentSize = self.owner.contentSize;
        if (contentSize.height < self.owner.frame.size.height) {
            contentSize.height = self.owner.frame.size.height;
        }

        if (self.loadMorePosition == SFPullRefreshPositionTop) {
            
            if (offset.y < 0) {
                self.loadMoreState = SFPullRefreshStateLoading;
                
                if ([self.loadMoreControl respondsToSelector:@selector(beginLoading)]) {
                    [self.loadMoreControl beginLoading];
                }
                
                if (self.loadMoreHandler)
                {
                    self.loadMoreHandler();
                }
                [UIView animateWithDuration:0.1 animations:^{
                    self.owner.contentInset = UIEdgeInsetsMake(self.loadMoreControl.frame.size.height+self.orignInsetTop, 0, 0, 0);
                }];
            }
        } else {
            
            float yMargin = self.owner.contentOffset.y + size.height - contentSize.height;
            
            if ( yMargin > 0) {  //footer will appeared
                
                self.loadMoreState = SFPullRefreshStateLoading;
                
                if ([self.loadMoreControl respondsToSelector:@selector(beginLoading)]) {
                    [self.loadMoreControl beginLoading];
                }
                
                if (self.loadMoreHandler)
                {
                    self.loadMoreHandler();
                }
                
                [UIView animateWithDuration:0.1 animations:^{
                    self.owner.contentInset = UIEdgeInsetsMake(self.orignInsetTop, 0, self.loadMoreControl.frame.size.height, 0);
                }];
            }
        }
    }
}

- (void)tableViewDidEndDragging
{
    if (self.refreshControl && self.refreshState == SFPullRefreshStateReleaseToRefresh) {
        
        self.isRefreshing = YES;
        self.refreshState = SFPullRefreshStateRefreshing;
        self.loadMoreState = SFPullRefreshStateNormal;
        if ([self.refreshControl respondsToSelector:@selector(beginRefreshing)]) {
            [self.refreshControl beginRefreshing];
        }
        
        if (self.refreshHandler) {
            self.refreshHandler();
        }
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            if (self.refreshPosition == SFPullRefreshPositionTop) {
                UIEdgeInsets inset = self.owner.contentInset;
                
                inset.top = self.refreshControl.frame.size.height+self.orignInsetTop;
                self.owner.contentInset = inset;
            } else {
                UIEdgeInsets inset = self.owner.contentInset;
                
                inset.bottom = self.refreshControl.frame.size.height;
                self.owner.contentInset = inset;
            }
            
        } completion:nil];
    }
}

@end