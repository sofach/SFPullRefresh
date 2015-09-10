//
//  SFRefreshControl.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  如果需要自定义refreshControl，则需要实现这个协议
 */
@protocol SFRefreshControlDelegate <NSObject>

- (void)willRefreshWithProgress:(CGFloat)progress; //添加将要刷新的效果
- (void)beginRefreshing; //添加开始刷新的效果
- (void)endRefreshing; //添加结束刷新的效果

@optional
- (void)setControlColor:(UIColor *)controlColor; //设置颜色

@end

@interface SFRefreshControl : UIControl <SFRefreshControlDelegate>

@end
