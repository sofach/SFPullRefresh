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
@property (strong, nonatomic) UILabel *reachedEndLabel;

@end

@implementation SFLoadMoreControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _tintColor = [UIColor colorWithWhite:110.0/255 alpha:1.0];
        [self setup];
    }
    return self;
}

- (void)setup
{
    _reachedEndLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _reachedEndLabel.backgroundColor = [UIColor clearColor];
    _reachedEndLabel.font = [UIFont systemFontOfSize:15.0];
    _reachedEndLabel.textColor = self.tintColor;
    _reachedEndLabel.textAlignment = NSTextAlignmentCenter;
    _reachedEndLabel.text = @"没有了";
    _reachedEndLabel.hidden = YES;
    [self addSubview:_reachedEndLabel];
    
    _loadingLayers = [NSMutableArray array];
    CGFloat w = self.frame.size.height*7/16;
    
    _loadingContainer = [[CALayer alloc] init];
    _loadingContainer.frame = CGRectMake(0, 0, w, w);
    _loadingContainer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self.layer addSublayer:_loadingContainer];
    
    
    for (int i=0; i<12; i++)
    {
        CALayer *layer = [[CALayer alloc] init];
        layer.backgroundColor = _tintColor.CGColor;
        layer.frame = CGRectMake(w/2-1, w/2-w*2/7, 2, w*2/7);
        layer.anchorPoint = CGPointMake(0.5, 1+3/4.0);
        layer.allowsEdgeAntialiasing = YES;
        layer.cornerRadius = 1.0f;
        layer.transform = CATransform3DMakeRotation(M_PI*i/6, 0, 0, 1);
        [_loadingContainer addSublayer:layer];
        [_loadingLayers addObject:layer];
    }
}




#pragma mark - private method
- (CAAnimation *)animationAtIndex:(NSInteger)index {
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1);
    opacityAnimation.toValue = @(0);
    opacityAnimation.duration = 1;
    opacityAnimation.repeatCount = INFINITY;
    opacityAnimation.timeOffset = 1*(1 - index / 12.0);
    return opacityAnimation;
}





#pragma mark - SFLoadMoreControlDelegate
- (void)beginLoading {
    _reachedEndLabel.hidden = YES;
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        CAAnimation *animation = [self animationAtIndex:idx];
        [layer addAnimation:animation forKey:nil];
        layer.hidden = NO;
    }];
}

- (void)endLoading {
    
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        
        [layer removeAllAnimations];
        layer.hidden = YES;
    }];
}

- (void)reachedEnd:(BOOL)reachedEnd
{
    if (reachedEnd) {
        _reachedEndLabel.hidden = NO;
    }
    else
    {
        _reachedEndLabel.hidden = YES;
    }

}

- (void)setReachedEndText:(NSString *)reachedEndText
{
    _reachedEndLabel.text = reachedEndText;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [_loadingLayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        [layer setBackgroundColor:_tintColor.CGColor];
    }];
}

@end
