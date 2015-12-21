//
//  SFLoadMoreControl.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  如果需要自定义loadMoreControl，需要实现这个协议
 */
@protocol SFLoadMoreControlDelegate <NSObject>

- (void)beginLoading; //在这里添加开始加载更多的效果
- (NSTimeInterval)endLoading; //在这里添加结束加载更多的效果
- (void)reachEndWithText:(NSString *)text; //在这里添加数据加载完的效果

@optional
- (void)setControlColor:(UIColor *)controlColor; //设置颜色

@end

@interface SFLoadMoreControl : UIView <SFLoadMoreControlDelegate>


@end
