//
//  SaveConfirm.m
//  Imageverse
//
//  Created by Main on 5/28/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "SaveConfirm.h"
#import "CircleLoader.h"
#import "UIColor+BFPaperColors.h"
#import "UIColor+BFKit.h"

#define SAVE_INITIAL_SAVE_SIZE 180.0f
#define SAVE_FINAL_SAVE_WIDTH 260.0f
#define SAVE_FINAL_SAVE_HEIGHT 100.0f
#define SAVE_LOADER_DIAMETER 100.0f
#define SAVE_LOADER_THICKNESS 6.0f
#define SAVE_INITIAL_ANIMATION_DURATION 0.2f
#define SAVE_FINAL_ANIMATION_DURATION 0.3f
#define SAVE_FINAL_LAG_TIME 0.7f
#define SAVE_SPRING_DAMPING 0.7f
#define SAVE_FONT_SIZE 31.0f
#define SAVE_FONT @"Verdana"
#define SAVE_BACKGROUND_ALPHA 0.3f

@interface SaveConfirm ()

    @property UIView * backgroundView;

    @property UIVisualEffectView * blurView;
    @property UIVisualEffectView * vibrancyView;

    @property CircleLoader * loader;

    @property UILabel * label;
@end

@implementation SaveConfirm

+ (instancetype)newSaveConfirm {
    return [[self alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0;
    
    UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _blurView.frame = CGRectMake(0, 0, SAVE_INITIAL_SAVE_SIZE, SAVE_INITIAL_SAVE_SIZE);
    //_blurView.backgroundColor = [UIColor colorWithColor:[UIColor paperColorBlueGray900] alpha:0.5];
    _blurView.center = self.center;
    _blurView.layer.cornerRadius = 16;
    _blurView.clipsToBounds = YES;
    _blurView.alpha = 0;
    
    UIVibrancyEffect * vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    _vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    _vibrancyView.frame = CGRectMake(0, 0, SAVE_INITIAL_SAVE_SIZE, SAVE_INITIAL_SAVE_SIZE);
    CGSize size = _blurView.frame.size;
    [_vibrancyView setCenter:CGPointMake(size.width/2, size.height/2)];
    
    _loader = [CircleLoader circleLoaderWithFrame:CGRectMake(0, 0, SAVE_LOADER_DIAMETER, SAVE_LOADER_DIAMETER) Colors:@[[UIColor paperColorCyanA400], [UIColor paperColorPinkA400]] Thickness:SAVE_LOADER_THICKNESS];
    _loader.center = self.center;
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SAVE_FINAL_SAVE_WIDTH, SAVE_FINAL_SAVE_HEIGHT)];
    _label.backgroundColor = [UIColor clearColor];
    _label.alpha = 0.4;
    _label.font = [UIFont fontWithName:SAVE_FONT size:SAVE_FONT_SIZE];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"";
    size = _vibrancyView.frame.size;
    [_label setCenter:CGPointMake(size.width/2, size.height/2)];

    [_vibrancyView.contentView addSubview:_label];
    //[vibrancyView.contentView addSubview:loader];
    [_blurView.contentView addSubview:_vibrancyView];
    
    [self addSubview:_backgroundView];
    [self addSubview:_blurView];
    [self addSubview:_loader];
}

- (void)show {
    _blurView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [_loader animate];
    
    [UIView animateWithDuration:SAVE_INITIAL_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = SAVE_BACKGROUND_ALPHA;
                         _blurView.alpha = 1;
                     } completion:^(BOOL finished) {
                         //Nothing on completion;
                     }];
    
    [UIView animateWithDuration:SAVE_INITIAL_ANIMATION_DURATION
                          delay:0
         usingSpringWithDamping:SAVE_SPRING_DAMPING
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _blurView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         //Nothing on completion
                     }];
}

- (void)finishedSaving {
    [_loader remove];
    [UIView animateWithDuration:SAVE_FINAL_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _label.text = @"Saved";
                         _blurView.frame = CGRectMake(0, 0, SAVE_FINAL_SAVE_WIDTH, SAVE_FINAL_SAVE_HEIGHT);
                         _vibrancyView.frame = CGRectMake(0, 0, SAVE_FINAL_SAVE_WIDTH, SAVE_FINAL_SAVE_HEIGHT);
                         _blurView.center = self.center;
                         CGSize size = _blurView.frame.size;
                         [_vibrancyView setCenter:CGPointMake(size.width/2, size.height/2)];
                         size = _vibrancyView.frame.size;
                         [_label setCenter:CGPointMake(size.width/2, size.height/2)];
                     } completion:^(BOOL finished) {
                         //
                     }];
    
    [UIView animateWithDuration:SAVE_FINAL_ANIMATION_DURATION
                          delay:SAVE_FINAL_LAG_TIME
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _backgroundView.alpha = 0;
                         _blurView.alpha = 0;
                     } completion:^(BOOL finished) {
                         //
                     }];
    
    [UIView animateWithDuration:SAVE_FINAL_ANIMATION_DURATION
                          delay:SAVE_FINAL_LAG_TIME
         usingSpringWithDamping:SAVE_SPRING_DAMPING
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _blurView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
