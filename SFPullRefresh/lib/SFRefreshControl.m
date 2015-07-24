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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _controlColor = [UIColor colorWithWhite:110.0/255 alpha:1.0];
        [self setup];
    }
    return self;
}

- (void)setup
{
    _refreshLayers = [NSMutableArray array];
    CGFloat w = self.frame.size.height*RefreshContainerRatio;
    
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



#pragma mark - private method
- (CAAnimation *)rotationAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI];
    rotationAnimation.duration = 0.5f;
    rotationAnimation.repeatCount = INFINITY;
    rotationAnimation.speed = 0.5f;
    return rotationAnimation;
}

- (CAAnimation *)opacityAnimationAtIndex:(NSInteger)index {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    opacityAnimation.duration = 1;
    opacityAnimation.repeatCount = INFINITY;
    opacityAnimation.timeOffset = 1*(1 - index*1.0/RefreshLayerCount);
    return opacityAnimation;
}

- (CAAnimation *)sizeAnimation {
    CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.height"];
    sizeAnimation.fromValue = [NSNumber numberWithFloat:(self.frame.size.height*RefreshContainerRatio/2)*RefreshLayerRatio];
    sizeAnimation.toValue = [NSNumber numberWithFloat:0];
    sizeAnimation.duration = 0.25f;
    sizeAnimation.repeatCount = 0;
    sizeAnimation.removedOnCompletion = NO;
    sizeAnimation.fillMode = kCAFillModeForwards;
    return sizeAnimation;
}

- (CAAnimation *)rotationAnimationAtIndex:(NSInteger)index {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:2*M_PI*index/RefreshLayerCount];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2*M_PI*index/RefreshLayerCount+M_PI/2];
    rotationAnimation.duration = 0.25f;
    rotationAnimation.repeatCount = 0;
    rotationAnimation.removedOnCompletion = YES;
    return rotationAnimation;
}



#pragma mark - SFPullRefreshControlDelegate
- (void)willRefreshWithProgress:(CGFloat)progress
{
    if (progress < 1.0/RefreshLayerCount) {
        return;
    }
    else if (progress>0 && progress<1) {
        _isRotating = NO;
        [_refreshContainer removeAllAnimations];
    }
    else
    {
        if (!_isRotating) {
            _isRotating = YES;
            [_refreshContainer removeAllAnimations];
            [_refreshContainer addAnimation:[self rotationAnimation] forKey:nil];
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
        [layer addAnimation:[self opacityAnimationAtIndex:idx] forKey:@"opacity"];
    }];
}

- (void)endRefreshing
{
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
        [layer addAnimation:[self sizeAnimation] forKey:nil];
        [layer addAnimation:[self rotationAnimationAtIndex:idx] forKey:nil];
    }];
    
    [CATransaction commit];
}

- (void)setControlColor:(UIColor *)controlColor
{
    _controlColor = controlColor;
    [_refreshLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        layer.backgroundColor = _controlColor.CGColor;
    }];
}
@end
