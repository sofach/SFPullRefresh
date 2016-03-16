//
//  SFCircleRefreshControl.h
//  SFPullRefresh
//
//  Created by 陈少华 on 15/12/4.
//  Copyright © 2015年 sofach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRefreshControl.h"

@interface SFCircleRefreshControl : UIView <SFRefreshControlDelegate>

@property (assign, nonatomic) CGFloat circleWidth;
@property (assign, nonatomic) CGFloat maxProgress;
@property (assign, nonatomic) CGFloat radius;

@end
