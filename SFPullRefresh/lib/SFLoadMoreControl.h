//
//  SFLoadMoreControl.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFLoadMoreControlDelegate <NSObject>

- (void)beginLoading;
- (void)endLoading;
- (void)reachedEnd:(BOOL)reachedEnd;

@optional
- (void)setReachedEndText:(NSString *)reachedEndText;
- (void)setTintColor:(UIColor *)tintColor;

@end

@interface SFLoadMoreControl : UIView <SFLoadMoreControlDelegate>

@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) NSString *reachedEndText;

@end
