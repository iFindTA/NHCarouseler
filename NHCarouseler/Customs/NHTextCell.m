//
//  NHTextCell.m
//  NHReuseCellPro
//
//  Created by hu jiaju on 15/11/4.
//  Copyright © 2015年 hu jiaju. All rights reserved.
//

#import "NHTextCell.h"

@interface NHTextCell ()

@property (nonnull, nonatomic, strong) UILabel *label;

@end

@implementation NHTextCell

- (nonnull instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super initWithIdentifier:identifier];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_label];
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
