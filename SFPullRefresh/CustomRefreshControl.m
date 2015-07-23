//
//  CustomRefreshControl.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/16.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "CustomRefreshControl.h"

@interface CustomRefreshControl ()

@property (strong, nonatomic) CAShapeLayer *leftGateLayer;
@property (strong, nonatomic) CAShapeLayer *rightGateLayer;
@property (strong, nonatomic) CAShapeLayer *ballLayer;

@end

@implementation CustomRefreshControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _leftGateLayer = [[CAShapeLayer alloc] init];
        _leftGateLayer.backgroundColor = [UIColor greenColor].CGColor;
        _leftGateLayer.fillColor = [UIColor lightGrayColor].CGColor;
        _leftGateLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _leftGateLayer.lineWidth = 4.0;
        _leftGateLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame.size.width/4-2, frame.size.height/4, 4, frame.size.height/2)].CGPath;
        [self.layer addSublayer:_leftGateLayer];
        
        _rightGateLayer = [[CAShapeLayer alloc] init];
        _rightGateLayer.backgroundColor = [UIColor greenColor].CGColor;
        _rightGateLayer.fillColor = [UIColor lightGrayColor].CGColor;
        _rightGateLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _rightGateLayer.lineWidth = 4.0;
        _rightGateLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(frame.size.width*3.0/4-2, frame.size.height/4, 4, frame.size.height/2)].CGPath;
        [self.layer addSublayer:_rightGateLayer];
        
        _ballLayer = [[CAShapeLayer alloc] init];
        _ballLayer.frame = CGRectMake(frame.size.width/4, frame.size.height/2, 6, 6);
        _ballLayer.backgroundColor = [UIColor blackColor].CGColor;
        _ballLayer.cornerRadius = 3;
        [self.layer addSublayer:_ballLayer];
    }
    return self;
}


- (CAAnimation *)bounceAnimation {
    
    CGPoint beginPoint = CGPointMake(self.frame.size.width/4, self.frame.size.height/2);
    CGPoint endPoint = CGPointMake(self.frame.size.width*3.0/4, self.frame.size.height/2);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animation];
    bounceAnimation.values = @[[NSValue valueWithCGPoint:beginPoint], [NSValue valueWithCGPoint:endPoint]];
    bounceAnimation.autoreverses = YES;
    bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    bounceAnimation.repeatCount = INFINITY;

    return bounceAnimation;
}


#pragma mark - SFPullRefreshControlDelegate
- (void)willRefreshWithProgress:(CGFloat)progress
{
    if (progress<0) {
        return;
    }
    if (progress>1) {
        progress = 1;
    }

    _leftGateLayer.hidden = NO;
    _rightGateLayer.hidden = NO;
    _ballLayer.hidden = NO;
    
    CGPoint position = _ballLayer.position;
    position.x = self.frame.size.width/4+self.frame.size.width*progress/2;
    _ballLayer.position = position;
}

- (void)beginRefreshing
{
    [_ballLayer addAnimation:[self bounceAnimation] forKey:@"position"];
}

- (void)endRefreshing
{
    [_ballLayer removeAllAnimations];
}

- (void)setTintColor:(UIColor *)tintColor{
    _leftGateLayer.fillColor = tintColor.CGColor;
    _rightGateLayer.strokeColor = tintColor.CGColor;
    _ballLayer.strokeColor = tintColor.CGColor;
}


@end
