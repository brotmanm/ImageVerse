//
//  CircleLoader.m
//  Imageverse
//
//  Created by Main on 5/24/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "CircleLoader.h"

#define CIRCLE_COLOR [UIColor blackColor]
#define CIRCLE_THICKNESS 3.0
#define CIRCLE_TIME 1.0

@interface CircleLoader ()

//The shape of our circle
@property CAShapeLayer * shape;

//These will stroke our path
@property CAAnimationGroup * animationGroup;

//Animate our colors
@property CAKeyframeAnimation * colorAnimation;

//Slowly rotate the entire circle
@property CABasicAnimation * rotationAnimation;

//Is the loader currently running through animations
@property (readwrite) BOOL animated;

@end

@implementation CircleLoader

+ (instancetype)circleLoaderWithFrame:(CGRect)frame {
    return [[CircleLoader alloc] initWithFrame:frame];
}

+ (instancetype)circleLoaderWithFrame:(CGRect)frame Colors:(NSArray<UIColor *> *)myColors Thickness:(CGFloat)lineWidth {
    CircleLoader * loader = [[CircleLoader alloc] initWithFrame:frame];
    loader.colors = myColors;
    loader.thickness = lineWidth;
    return loader;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _colors = @[CIRCLE_COLOR];
        _thickness = CIRCLE_THICKNESS;
        [self setup];
    }
    
    return self;
}

//Setup our shape layer, and then setup our animations
- (void)setup {
    self.shape = [CAShapeLayer layer];
    
    [self setupPath];
    
    self.shape.strokeColor = [UIColor clearColor].CGColor;
    self.shape.fillColor = [UIColor clearColor].CGColor;
    self.shape.frame = self.bounds;
    self.shape.lineWidth = self.thickness;
    [self.layer addSublayer:self.shape];
    
    [self setupAnimations];
    
    self.animated = NO;
}

//Setup our circular path
- (void)setupPath {
    CGFloat diameter = MIN(self.bounds.size.width, self.bounds.size.height) - self.thickness;
    UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, diameter, diameter)];
    self.shape.path = circlePath.CGPath;
    
}

//Property method, we want to do some things if we modify the thickness
- (void)setThickness:(CGFloat)thickness {
    _thickness = thickness;
    self.shape.lineWidth = thickness;
    [self setupPath];
}

//Property method, we want to do some things if we modify the colors
- (void)setColors:(NSArray<UIColor *> *)colors {
    if (colors.count > 0) {
        _colors = colors;
    }
    [self createColorAnimation];
}

//Setup our animations
- (void)setupAnimations {
    
    //Start with our circle fully drawn, and use this to "erase" it, ease in to this
    CABasicAnimation * beginAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    beginAnimation.duration = CIRCLE_TIME;
    beginAnimation.fromValue = @0;
    beginAnimation.toValue = @1;
    beginAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //Once our circle is "erased" from above, redraw it using this, ease out of this
    CABasicAnimation * endAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    endAnimation.duration = CIRCLE_TIME;
    endAnimation.fromValue = @0;
    endAnimation.toValue = @1;
    endAnimation.beginTime = CIRCLE_TIME;
    endAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    //Combine the two animations above into an infinite looping animation group
    self.animationGroup = [CAAnimationGroup animation];
    self.animationGroup.animations = @[beginAnimation, endAnimation];
    self.animationGroup.duration = CIRCLE_TIME * 2.0;
    self.animationGroup.repeatCount = INFINITY;

    //Color animation below
    [self createColorAnimation];
    
    //Rotate our circle completely and loop this infinitely
    self.rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    float random = 2.0 + (float)rand() / RAND_MAX;
    self.rotationAnimation.duration = CIRCLE_TIME * random;
    self.rotationAnimation.repeatCount = INFINITY;
    self.rotationAnimation.fromValue = @0;
    self.rotationAnimation.toValue = [NSNumber numberWithDouble:2*M_PI];
}

//Use a keyframeanimation to animate our changing of color
- (void)createColorAnimation {
    self.colorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    NSArray * modifiedColorArray = [self getCGColorArray];
    self.colorAnimation.values = modifiedColorArray;
    
    //Auto calculate the timing
    //This works instead of using explicit key timing
    self.colorAnimation.calculationMode = kCAAnimationPaced;
    
    //Give each color TIME/3 time
    self.colorAnimation.duration = CIRCLE_TIME * modifiedColorArray.count / 3;
    self.colorAnimation.repeatCount = INFINITY;
}

//Convert our our colors into useable cg colors for our animation
- (NSArray *)getCGColorArray {
    NSMutableArray * cgColors;
    
    //"Smart" color modification
    //Check if we are starting and ending on the same color (which we want for smoothness)
    //If we are not, we force it, and double up every other color between to compensate
    if (![self.colors.firstObject isEqual:self.colors.lastObject]) {
        cgColors = [NSMutableArray arrayWithCapacity:self.colors.count * 2];
        [cgColors addObject:(id)self.colors.firstObject.CGColor];
        for (NSUInteger i = 1; i < self.colors.count; i++) {
            [cgColors addObject:(id)[self.colors objectAtIndex:i].CGColor];
            [cgColors addObject:(id)[self.colors objectAtIndex:i].CGColor];
        }
        for (int i = (int)self.colors.count - 2; i >= 0; i--) {
            [cgColors addObject:(id)[self.colors objectAtIndex:i].CGColor];
            [cgColors addObject:(id)[self.colors objectAtIndex:i].CGColor];
        }
    } else {
        cgColors = [NSMutableArray arrayWithCapacity:self.colors.count];
        for (UIColor * color in self.colors) {
            [cgColors addObject:(id)color.CGColor];
        }
    }
    
    return cgColors;
}

- (void)animate {
    if (!self.animated) {
        [self.shape addAnimation:self.animationGroup forKey:@"strokeAnimation"];
        [self.shape addAnimation:self.rotationAnimation forKey:@"rotationAnimation"];
        [self.shape addAnimation:self.colorAnimation forKey:@"colorAnimation"];
        self.animated = YES;
    }
}

- (void)pause {
    if  (self.animated) {
        [self.shape removeAllAnimations];
        self.animated = NO;
    }
}

- (void)remove {
    [self removeFromSuperview];
}

@end
