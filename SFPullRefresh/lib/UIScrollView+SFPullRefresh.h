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

@interface UIScrollView (SFPullRefresh)

/**
 *  添加刷新功能
 *
 *  @param refreshHandler 刷新的处理
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler;

/**
 *  添加刷新功能，必须在加到superView之前调用
 *
 *  @param refreshHandler       刷新的处理
 *  @param customRefreshControl 自定义刷新效果，传nil则使用默认效果
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl;

/**
 *  添加加载更多功能，必须在加到superView之前调用
 *
 *  @param loadMoreHandler 加载更多的处理
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler;

/**
 *  添加加载更多功能
 *
 *  @param loadMoreHandler       加载更多的处理
 *  @param customLoadMoreControl 自定义的loadMoreControl，传nil则使用默认效果
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl;

/**
 *  添加加载更多功能
 *
 *  @param loadMoreHandler       加载更多的处理
 *  @param customLoadMoreControl 自定义的loadMoreControl，传nil则使用默认效果
 *  @param offsety               加载更多触发的offset，默认0
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl loadMoreTriggerOffsetY:(CGFloat)offsety;

/**
 *  是否正在刷新，可以用来判断是否该清空数据
 */
- (BOOL)sf_isRefreshing;

/**
 *  结束加载或刷新，需要在请求结束后调用
 */
- (void)sf_finishLoading;

- (void)sf_finishLoadingAnimated:(BOOL)animated;

- (void)sf_finishLoadingWithResult:(BOOL)result;

- (void)sf_finishLoadingAnimated:(BOOL)animated result:(BOOL)result;

/**
 *  刷新
 *
 *  @param animated 是否显示动画
 */
- (void)sf_refreshAnimated:(BOOL)animated;

/**
 *  加载更多
 *
 *  @param animated 是否显示动画
 */
- (void)sf_loadMoreAnimated:(BOOL)animated;

/**
 *  设置到达底部，需要在数据加载完时调用。
 */
- (void)sf_reachEndWithText:(NSString *)text;

/**
 *  自定义到达底部的view，需要在数据加载完时调用。
 */
- (void)sf_reachEndWithView:(UIView *)view;

/**
 *  显示自定义提示界面，可用于数据为空，或者请求错误的提示语
 *  注意，必须得在sf_finishLoading之后调用
 *
 *  @param hintsView 提示界面
 */
- (void)sf_showHintsView:(UIView *)hintsView;

/**
 *  是否自动刷新，必须addRefreshHandler
 */
- (void)sf_autoRefresh:(BOOL)autoRefresh;

- (void)sf_setLoadingTimeout:(NSTimeInterval)timeout;

/**
 *  设置refreshControl和loadMoreControl的颜色
 *
 *  @param controlColor 颜色
 */
- (void)sf_setControlColor:(UIColor *)controlColor;

@end
