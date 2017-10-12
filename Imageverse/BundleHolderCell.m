//
//  BundleHolderCell.m
//  Imageverse
//
//  Created by Main on 5/24/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "BundleHolderCell.h"

#define BUNDLE_CELL_CORNER_RADIUS 6

@interface BundleHolderCell ()

@end

@implementation BundleHolderCell

//All just standard cell stuff below, this is just wrapping the BundleHolder class into a UICollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setup {
    if (!self.bundleHolder) {
        self.bundleHolder = [BundleHolder bundleHolderWithFrame:self.contentView.bounds];
        self.bundleHolder.clipsToBounds = YES;
        [self.contentView addSubview:self.bundleHolder];
    }
    
    self.layer.cornerRadius = BUNDLE_CELL_CORNER_RADIUS;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.bundleHolder.loading = YES;
    [self.bundleHolder toggleVisuals];
}

@end
