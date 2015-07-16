//
//  SFRefreshControl.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFRefreshControlDelegate <NSObject>

- (void)willRefreshWithProgress:(CGFloat)progress;
- (void)beginRefreshing;
- (void)endRefreshing;

@optional
- (void)setTintColor:(UIColor *)tintColor;

@end

@interface SFRefreshControl : UIControl <SFRefreshControlDelegate>

@property (strong, nonatomic) UIColor *tintColor;

@end
