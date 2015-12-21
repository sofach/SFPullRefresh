//
//  SFCircleRefreshControl.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/12/4.
//  Copyright © 2015年 sofach. All rights reserved.
//

#import "SFCircleRefreshControl.h"

#define MaxProgress 0.9f

@interface SFCircleRefreshControl ()

@property (strong, nonatomic) CAShapeLayer *progressLayer;

@property (assign, nonatomic) BOOL animating;

@end

@implementation SFCircleRefreshControl

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 2.0f;
    }
    return _progressLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.progressLayer];
        
        CGFloat w = frame.size.height*3/5;
        [self.progressLayer setBounds:CGRectMake(0, 0, w, w)];
        self.progressLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        CGFloat radius = CGRectGetHeight(self.progressLayer.bounds)/2 - self.progressLayer.lineWidth/2;
        CGFloat startAngle = (CGFloat)(0);
        CGFloat endAngle = (CGFloat)(2*M_PI);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressLayer.bounds), CGRectGetMidY(self.progressLayer.bounds)) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        self.progressLayer.path = path.CGPath;
        self.progressLayer.strokeStart = 0.f;
        self.progressLayer.strokeEnd = 0.f;
    }
    return self;
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    _progressLayer.lineWidth = circleWidth;
}

- (void)setAnimating:(BOOL)animating {
    if ((!_animating) ^ animating) {
        return;
    }
    _animating = animating;
    if (_animating) {
        [self.progressLayer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"transform.rotation";
        animation.duration = 1.f;
        animation.fromValue = @(0.f);
        animation.toValue = @(2 * M_PI);
        animation.repeatCount = INFINITY;
        [self.progressLayer addAnimation:animation forKey:@"rotation"];
    } else {
        [self.progressLayer removeAnimationForKey:@"rotation"];
    }
}



#pragma mark - SFRefreshControlDelegate
- (void)willRefreshWithProgress:(CGFloat)progress {

    if (progress>0 && progress<MaxProgress) {
        self.animating = NO;
        self.progressLayer.strokeStart = 0;
        self.progressLayer.strokeEnd = progress;
    } else {
        if (self.animating) {
            return;
        }
        self.animating = YES;
    }
}

- (void)beginRefreshing {
    self.animating = YES;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = MaxProgress;
}

- (NSTimeInterval)endRefreshing {
    self.animating = NO;    
    self.progressLayer.strokeEnd = 0.0;
    self.progressLayer.strokeStart = 0.0;

    return 0.25f;
}

- (void)setControlColor:(UIColor *)controlColor {
    self.progressLayer.strokeColor = controlColor.CGColor;
}

@end
