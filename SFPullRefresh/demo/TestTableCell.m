//
//  TestTableCell.m
//  SFPullRefresh
//
//  Created by 陈少华 on 15/7/23.
//  Copyright (c) 2015年 sofach. All rights reserved.
//

#import "TestTableCell.h"

@interface TestTableCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;

@end

@implementation TestTableCell

- (void)awakeFromNib {
    // Initialization code
    _label.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width-20;
    _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    _iconImgView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIcon:(NSString *)iconName string:(NSString *)str
{
    _iconImgView.image = [UIImage imageNamed:iconName];
    _label.text = str;
}

@end
