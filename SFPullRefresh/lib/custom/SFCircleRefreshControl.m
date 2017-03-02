//
//  SFCircleRefreshControl.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/12/4.
//  Copyright © 2015年 sofach. All rights reserved.
//

#import "SFCircleRefreshControl.h"

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
        _progressLayer.lineWidth = 1.0f;
    }
    return _progressLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.progressLayer];
        
        _radius = frame.size.height*2.0/5;
        self.progressLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _maxProgress = 0.95;
        [self resetProgressLayer];
        self.progressLayer.strokeStart = 0.f;
        self.progressLayer.strokeEnd = 0.f;
    }
    return self;
}

- (void)resetProgressLayer {
    [self.progressLayer setBounds:CGRectMake(0, 0, _radius, _radius)];
    CGFloat radius = CGRectGetHeight(self.progressLayer.bounds)/2 - self.progressLayer.lineWidth/2;
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressLayer.bounds), CGRectGetMidY(self.progressLayer.bounds)) radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    _progressLayer.lineWidth = circleWidth;
    [self resetProgressLayer];
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

    if (progress>0.01 && progress<_maxProgress) {
        self.animating = NO;
        self.progressLayer.strokeStart = 0;
        self.progressLayer.strokeEnd = progress;
    } else if (progress<=0.01) {
        self.animating = NO;
        self.progressLayer.strokeStart = 0;
        self.progressLayer.strokeEnd = 0;
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
    self.progressLayer.strokeEnd = _maxProgress;
}

- (NSTimeInterval)endRefreshing {
    self.animating = NO;
    self.progressLayer.strokeStart = 0;
    self.progressLayer.strokeEnd = 0;
    return 0.25f;
}

- (void)setControlColor:(UIColor *)controlColor {
    self.progressLayer.strokeColor = controlColor.CGColor;
}

@end
