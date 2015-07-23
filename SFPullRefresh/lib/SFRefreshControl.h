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

- (void)willRefreshWithProgress:(CGFloat)progress;
- (void)beginRefreshing;
- (void)endRefreshing;

@optional
- (void)setTintColor:(UIColor *)tintColor;

@end

@interface SFRefreshControl : UIControl <SFRefreshControlDelegate>


@end
