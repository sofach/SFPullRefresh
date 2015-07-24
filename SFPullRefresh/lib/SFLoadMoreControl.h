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

- (void)beginLoading;
- (void)endLoading;
- (void)reachEndWithText:(NSString *)text;

@optional
- (void)setControlColor:(UIColor *)controlColor;

@end

@interface SFLoadMoreControl : UIView <SFLoadMoreControlDelegate>


@end
