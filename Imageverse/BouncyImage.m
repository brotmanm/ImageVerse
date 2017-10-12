//
//  BouncyImage.m
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "BouncyImage.h"

@interface BouncyImage ()

@property UIImageView * imageView;

@end

@implementation BouncyImage
@synthesize allowBounce;

+ (instancetype)bouncyImageWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;

    [self addSubview:self.imageView];
    
    allowBounce = YES;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (allowBounce) [self bounceIn];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (allowBounce) [self bounceOut];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (allowBounce) [self bounceIn];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (allowBounce) [self bounceOut];
}

- (void)bounceIn {
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{self.transform = CGAffineTransformMakeScale( 0.9, 0.9);}
                     completion:^(BOOL finished) {}];
}

- (void)bounceOut {
    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{self.transform = CGAffineTransformMakeScale( 1.0, 1.0);}
                     completion:^(BOOL finished) {}];
}

@end
