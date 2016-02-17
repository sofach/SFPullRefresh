//
//  SFLoadMoreControl.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/14.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "SFLoadMoreControl.h"

@interface SFLoadMoreControl ()

@property (strong, nonatomic) NSMutableArray *loadingLayers;
@property (strong, nonatomic) CALayer *loadingContainer;
@property (strong, nonatomic) UILabel *reachEndLabel;

@property (strong, nonatomic) UIColor *controlColor;

@end

@implementation SFLoadMoreControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _controlColor = [UIColor colorWithWhite:110.0/255 alpha:1.0];
        _reachEndLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _reachEndLabel.backgroundColor = [UIColor clearColor];
        _reachEndLabel.font = [UIFont systemFontOfSize:15.0];
        _reachEndLabel.textColor = self.controlColor;
        _reachEndLabel.textAlignment = NSTextAlignmentCenter;
        _reachEndLabel.text = @"没有了";
        _reachEndLabel.hidden = YES;
        [self addSubview:_reachEndLabel];
        
        _loadingLayers = [NSMutableArray array];
        CGFloat w = self.frame.size.height*7/16;
        if (w>25) {
            w = 25;
        }
        _loadingContainer = [[CALayer alloc] init];
        _loadingContainer.frame = CGRectMake(0, 0, w, w);
        _loadingContainer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self.layer addSublayer:_loadingContainer];
        
        
        for (int i=0; i<12; i++)
        {
            CALayer *layer = [[CALayer alloc] init];
            layer.backgroundColor = _controlColor.CGColor;
            layer.frame = CGRectMake(w/2-1, w/2-w*2/7, 2, w*2/7);
            layer.anchorPoint = CGPointMake(0.5, 1+3/4.0);
            layer.allowsEdgeAntialiasing = YES;
            layer.cornerRadius = 1.0f;
            layer.hidden = YES;
            layer.transform = CATransform3DMakeRotation(M_PI*i/6, 0, 0, 1);
            [_loadingContainer addSublayer:layer];
            [_loadingLayers addObject:layer];
        }
    }
    return self;
}








#pragma mark - SFLoadMoreControlDelegate
- (void)beginLoading {
    _reachEndLabel.hidden = YES;
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(1);
        opacityAnimation.toValue = @(0);
        opacityAnimation.duration = 1;
        opacityAnimation.repeatCount = INFINITY;
        opacityAnimation.timeOffset = 1*(1 - idx / 12.0);
        [layer addAnimation:opacityAnimation forKey:nil];
        layer.hidden = NO;
    }];
}

- (NSTimeInterval)endLoading {
    
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        [layer removeAllAnimations];
        layer.hidden = YES;
    }];
    return 0.25;
}

- (void)reachEndWithText:(NSString *)text
{
    _reachEndLabel.hidden = NO;
    _reachEndLabel.text = text?text:@"";
}

- (void)setReachEndText:(NSString *)reachedEndText
{
    _reachEndLabel.text = reachedEndText;
}

- (void)setControlColor:(UIColor *)controlColor
{
    _controlColor = controlColor;
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [layer setBackgroundColor:_controlColor.CGColor];
    }];
}

@end
