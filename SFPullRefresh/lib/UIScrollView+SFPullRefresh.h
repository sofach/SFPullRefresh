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

/**
 *  添加刷新功能，必须在加到superView之前调用
 *
 *  @param refreshHandler 刷新的处理
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler;

/**
 *  添加刷新功能，必须在加到superView之前调用
 *
 *  @param refreshHandler       刷新的处理
 *  @param position             刷新的位置，可以选择放在顶部或者底部
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position;

/**
 *  添加刷新功能，必须在加到superView之前调用
 *
 *  @param refreshHandler       刷新的处理
 *  @param position             刷新的位置，可以选择放在顶部或者底部
 *  @param customRefreshControl 自定义刷新效果，传nil则使用默认效果
 */
- (void)sf_addRefreshHandler:(void(^)(void))refreshHandler position:(SFPullRefreshPosition)position customRefreshControl:(UIView<SFRefreshControlDelegate> *)customRefreshControl;

/**
 *  添加加载更多功能，必须在加到superView之前调用
 *
 *  @param loadMoreHandler 加载更多的处理
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler;

/**
 *  添加加载更多功能，必须在加到superView之前调用
 *
 *  @param loadMoreHandler       加载更多的处理
 *  @param position              刷新的位置，可以选择放在顶部或者底部
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position;

/**
 *  添加加载更多功能，必须在加到superView之前调用
 *
 *  @param loadMoreHandler       加载更多的处理
 *  @param position              加载更多的位置，可以选择放在顶部或者底部
 *  @param customLoadMoreControl 自定义的loadMoreControl，传nil则使用默认效果
 */
- (void)sf_addLoadMoreHandler:(void(^)(void))loadMoreHandler position:(SFPullRefreshPosition)position customLoadMoreControl:(UIView<SFLoadMoreControlDelegate> *)customLoadMoreControl;

/**
 *  是否正在刷新，可以用来判断是否该清空数据
 *
 *  @return
 */
- (BOOL)sf_isRefreshing;

/**
 *  当前加载的第几页，如果是顺序加载数据，没有奇葩的需求，可以用这个参数作为请求页码
 *  会在刷新时设为0，当加载了数据会自动加1
 *
 *  @return
 */
- (NSUInteger)sf_page;

/**
 *  结束加载或刷新，需要在请求结束后调用
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
 *  显示提示语，可用于数据为空，或者请求错误的提示语
 *  注意，必须得在sf_finishLoading之后调用
 *
 *  @param hints 提示语
 */
- (void)sf_showHints:(NSString *)hints;

/**
 *  显示自定义提示界面，可用于数据为空，或者请求错误的提示语
 *  注意，必须得在sf_finishLoading之后调用
 *
 *  @param hintsView 提示界面
 */
- (void)sf_showHintsView:(UIView *)hintsView;

/**
 *  是否自动刷新
 */
- (void)sf_autoRefresh:(BOOL)autoRefresh;

/**
 *  设置refreshControl和loadMoreControl的颜色
 *
 *  @param tintColor 颜色
 */
- (void)sf_setControlColor:(UIColor *)controlColor;

@end
