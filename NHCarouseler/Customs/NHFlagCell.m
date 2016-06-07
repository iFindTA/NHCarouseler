//
//  NHFlagCell.m
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/11/4.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHFlagCell.h"

@interface NHFlagCell ()

@property (nonnull, nonatomic, strong) UIImageView *imgView;

@end

@implementation NHFlagCell

- (nonnull instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imgView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    self.imgView.image = image;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
