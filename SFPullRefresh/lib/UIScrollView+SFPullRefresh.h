//
//  UIScrollView+SFPullRefresh.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRefreshControl.h"
#import "SFLoadMoreControl.h"

typedef enum{
    SFPullRefreshPositionTop = 1,
    SFPullRefreshPositionBottom = -1
} SFPullRefreshPosition;

@interface UIScrollView (SFPullRefresh)

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler;

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl;

- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl position:(SFPullRefreshPosition)position;

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler;

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl;

- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl position:(SFPullRefreshPosition)position;

- (NSInteger)sf_page;

/**
 *  结束加载或刷新
 */
- (void)sf_finishLoading;

/**
 *  刷新
 */
- (void)sf_refreshAnimated:(BOOL)animated;

/**
 *  加载更多
 */
- (void)sf_loadMoreAnimated:(BOOL)animated;

/**
 *  需要在数据加载完时调用。
 */
- (void)sf_reachEnd;

/**
 *  是否正在刷新，可以用来判断是否该清空数据
 *
 *  @return
 */
- (BOOL)sf_isRefreshing;

/**
 *  设置refreshControl和loadMoreControl的颜色
 *
 *  @param tintColor 颜色
 */
- (void)sf_setTintColor:(UIColor *)tintColor;

@end
