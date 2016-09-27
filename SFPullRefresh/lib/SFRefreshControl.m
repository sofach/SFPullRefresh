//
//  SFRefreshControl.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFRefreshControl.h"

#define RefreshLayerCount 12
#define RefreshContainerRatio (7.0/16)
#define RefreshLayerRatio (4.0/7)

@interface SFRefreshControl ()

@property (assign, nonatomic) BOOL isRotating;

@property (strong, nonatomic) CALayer *refreshContainer;
@property (strong, nonatomic) NSMutableArray *refreshLayers;

@property (strong, nonatomic) UILabel *reachedEndLabel;
@property (strong, nonatomic) UIColor *controlColor;

@end

@implementation SFRefreshControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _controlColor = [UIColor colorWithWhite:110.0/255 alpha:1.0];
        _refreshLayers = [NSMutableArray array];
        CGFloat w = self.frame.size.height*RefreshContainerRatio;
        if (w>30) {
            w = 30;
        }
        _refreshContainer = [[CALayer alloc] init];
        _refreshContainer.frame = CGRectMake(0, 0, w, w);
        _refreshContainer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self.layer addSublayer:_refreshContainer];
        
        for (int i=0; i<RefreshLayerCount; i++) {
            
            CALayer *layer = [[CALayer alloc] init];
            layer.backgroundColor = _controlColor.CGColor;
            layer.frame = CGRectMake(0, 0, 2, (w/2)*RefreshLayerRatio);
            layer.anchorPoint = CGPointMake(0.5, 1+(1-RefreshLayerRatio)/RefreshLayerRatio);
            layer.position = CGPointMake(w/2, w/2);
            layer.allowsEdgeAntialiasing = YES;
            layer.cornerRadius = 1.0f;
            layer.hidden = YES;
            layer.transform = CATransform3DMakeRotation(2*M_PI*i/RefreshLayerCount, 0, 0, 1);
            [_refreshContainer addSublayer:layer];
            [_refreshLayers addObject:layer];
        }
    }
    return self;
}



#pragma mark - SFPullRefreshControlDelegate
- (void)willRefreshWithProgress:(CGFloat)progress
{
    if (progress>0.01 && progress<1) {
        _isRotating = NO;
        [_refreshContainer removeAllAnimations];
    } else if (progress<=0.01) {
        _isRotating = NO;
        [_refreshContainer removeAllAnimations];
    }  else {
        if (!_isRotating) {
            _isRotating = YES;
            [_refreshContainer removeAllAnimations];
            
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
            rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI];
            rotationAnimation.duration = 0.5f;
            rotationAnimation.repeatCount = INFINITY;
            rotationAnimation.speed = 0.5f;
            [_refreshContainer addAnimation:rotationAnimation forKey:nil];
        }
    }
    CGFloat w = self.frame.size.height*RefreshContainerRatio;
    _refreshContainer.frame = CGRectMake(0, 0, w, w);
    _refreshContainer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    for (int i=1; i<=RefreshLayerCount; i++) {
        CALayer *layer = _refreshLayers[i-1];
        if (i <= progress * RefreshLayerCount) {
            layer.hidden = NO;
        }else{
            layer.hidden = YES;
        }
    }
}

- (void)beginRefreshing
{
    _isRotating = NO;
    [_refreshContainer removeAllAnimations];
    [_refreshLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(1);
        opacityAnimation.toValue = @(0);
        opacityAnimation.duration = 1;
        opacityAnimation.repeatCount = INFINITY;
        opacityAnimation.timeOffset = 1*(1 - idx*1.0/RefreshLayerCount);
        [layer addAnimation:opacityAnimation forKey:@"opacity"];
    }];
}

- (NSTimeInterval)endRefreshing {
    
    NSTimeInterval interval = 0.25;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [_refreshLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
            [layer removeAllAnimations];
            layer.hidden = YES;
        }];
    }];
    [_refreshContainer removeAllAnimations];
    [_refreshLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [layer removeAnimationForKey:@"opacity"];
        
        CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
        sizeAnimation.fromValue = [NSNumber numberWithFloat:(self.frame.size.height*RefreshContainerRatio/2)*RefreshLayerRatio];
        sizeAnimation.toValue = [NSNumber numberWithFloat:2];
        sizeAnimation.duration = interval;
        sizeAnimation.repeatCount = 0;
        sizeAnimation.removedOnCompletion = NO;
        sizeAnimation.fillMode = kCAFillModeForwards;
        [layer addAnimation:sizeAnimation forKey:nil];
        
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:2*M_PI*idx/RefreshLayerCount];
        rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI*idx/RefreshLayerCount+M_PI/2];
        rotationAnimation.duration = interval;
        rotationAnimation.repeatCount = 0;
        rotationAnimation.removedOnCompletion = YES;
        [layer addAnimation:rotationAnimation forKey:nil];
    }];
    
    [CATransaction commit];
    
    return interval;
}

- (void)setControlColor:(UIColor *)controlColor
{
    _controlColor = controlColor;
    [_refreshLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        layer.backgroundColor = _controlColor.CGColor;
    }];
}
@end
