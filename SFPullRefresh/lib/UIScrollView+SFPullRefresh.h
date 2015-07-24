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

@class SFPullRefreshContext;
@interface UIScrollView (SFPullRefresh)

@property (strong, nonatomic, readonly) SFPullRefreshContext *context;

/**
 *  添加刷新功能
 *
 *  @param refreshHandler 刷新的处理
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler;

/**
 *  添加刷新功能
 *
 *  @param refreshHandler       刷新的处理
 *  @param customRefreshControl 自定义的刷新效果，传nil则使用默认效果
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl;

/**
 *  添加刷新功能
 *
 *  @param refreshHandler       刷新的处理
 *  @param customRefreshControl 自定义刷新效果，传nil则使用默认效果
 *  @param position             刷新的位置，可以选择放在顶部或者底部
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl position:(SFPullRefreshPosition)position;

/**
 *  添加加载更多功能
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
 *  @param position              加载更多的位置，可以选择放在顶部或者底部
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl position:(SFPullRefreshPosition)position;

/**
 *  是否正在刷新，可以用来判断是否该清空数据
 *
 *  @return
 */
- (BOOL)sf_isRefreshing;

/**
 *  结束加载或刷新
 */
- (void)sf_finishLoading;

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
 *  设置refreshControl和loadMoreControl的颜色
 *
 *  @param tintColor 颜色
 */
- (void)sf_setControlColor:(UIColor *)controlColor;

@end
