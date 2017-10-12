//
//  MultiButton.m
//  Imageverse
//
//  Created by Main on 7/13/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "MultiButton.h"
#import "BFPaperButton.h"
#import "ViewUtils.h"

#define DIAMETER 50.0
#define MAX_BUTTONS 18
#define MAIN_BUTTON_INDEX 1000

#define OPEN_ANIMATION_DURATION 0.5
#define CLOSE_ANIMATION_DURATION 0.5
#define SPREAD_DISTANCE 240

#define LABEL_HEIGHT 40
#define LABEL_BUTTON_CUSHION 5

@interface MultiButton ()

@property (readwrite) NSMutableArray<NSString *> * buttonLabels;
@property (readwrite) NSMutableArray<NSString *> * buttonIcons;

@property NSMutableArray<BFPaperButton *> * subButtons;
@property NSMutableArray<UILabel *> * subLabels;
@property BFPaperButton * mainButton;
@property UIView * darkView;

@property BOOL isOpen;

@end


@implementation MultiButton

+ (instancetype)multiButtonWithPosition:(CGPoint)position MainIcon:(NSString *)mainIcon Labels:(NSArray<NSString *> *)labels Icons:(NSArray<NSString *> *)icons ButtonColor:(UIColor *)buttonColor TextColor:(UIColor *)textColor TextFont:(UIFont *)font SelectedItemBlock:(MultiButtonSelectedBlock)selectedBlock {
    return [[self alloc] initWithPosition:position MainIcon:mainIcon Labels:labels Icons:icons ButtonColor:buttonColor TextColor:textColor TextFont:font SelectedItemBlock:selectedBlock];
}

- (instancetype)initWithPosition:(CGPoint)position MainIcon:(NSString *)mainIcon Labels:(NSArray<NSString *> *)labels Icons:(NSArray<NSString *> *)icons ButtonColor:(UIColor *)buttonColor TextColor:(UIColor *)textColor TextFont:(UIFont *)font SelectedItemBlock:(MultiButtonSelectedBlock)selectedBlock {
    if (self = [super initWithFrame:CGRectMake(position.x, position.y, DIAMETER, DIAMETER)]) {
        _buttonLabels = [labels mutableCopy];
        _buttonIcons = [icons mutableCopy];
        _buttonBackgroundColor = buttonColor;
        _labelColor = textColor;
        _iconColor = textColor;
        _spreadDistance = SPREAD_DISTANCE;
        _blockOnSelection = selectedBlock;
        _labelFont = font;
        _iconFont = font;
        _mainButtonIcon = mainIcon;
        _mainButtonFont = font;
        _mainButtonBackgroundColor = buttonColor;
        _mainButtonIconColor = textColor;
        _closeIcon = mainIcon;
        
        [self setup];
    }
    
    return self;
}

- (void)setup {
    _subButtons = [[NSMutableArray alloc] initWithCapacity:_buttonLabels.count];
    _subLabels = [[NSMutableArray alloc] initWithCapacity:_buttonLabels.count];
    
    self.backgroundColor = [UIColor clearColor];
    _darkView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    _darkView.backgroundColor  = [UIColor blackColor];
    
    _mainButton = [self formattedButtonWithIndex:MAIN_BUTTON_INDEX];
    [_mainButton addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.mainButton];
    
    for (int i = 0; i < self.buttonLabels.count && i < MAX_BUTTONS; i++) {
        BFPaperButton * buttonToAdd = [self formattedButtonWithIndex:i];
        [buttonToAdd addTarget:self action:@selector(subButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_subButtons addObject:buttonToAdd];
        
        UILabel * labelToAdd = [self formattedLabelWithIndex:i];
        [_subLabels addObject:labelToAdd];
    }
}

- (BFPaperButton *)formattedButtonWithIndex:(int)index {
    BFPaperButton * paperButton = [[BFPaperButton alloc] initWithFrame:self.bounds raised:YES];
    paperButton.backgroundColor = _buttonBackgroundColor;
    [paperButton setTitleColor:_iconColor forState:UIControlStateNormal];
    [paperButton setTitleFont:_iconFont];
    if (index == MAIN_BUTTON_INDEX) {
        [paperButton setTitle:_mainButtonIcon forState:UIControlStateNormal];
    } else {
        [paperButton setTitle:[_buttonIcons objectAtIndex:index] forState:UIControlStateNormal];
    }
    paperButton.tag = index;
    paperButton.cornerRadius = paperButton.height / 2;
    return paperButton;
}

- (UILabel *)formattedLabelWithIndex:(int)index {
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, LABEL_HEIGHT)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = _labelColor;
    label.font = _labelFont;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [_buttonLabels objectAtIndex:index];
    [label sizeToFit];
    return label;
}

- (void)subButtonPressed:(UIButton *)sender {
    int index = (int)sender.tag;
    self.blockOnSelection(index);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    for (BFPaperButton* button in _subButtons) {
        [button setFrame:frame];
    }
}

- (void)setLabel:(NSString *)label ForIndex:(int)index {
    [_buttonLabels replaceObjectAtIndex:index withObject:label];
    [[_subLabels objectAtIndex:index] setText:label];
    [[_subLabels objectAtIndex:index] sizeToFit];
}

- (void)setIcon:(NSString *)icon ForIndex:(int)index {
    [_buttonIcons replaceObjectAtIndex:index withObject:icon];
    if (self.isOpen) {
        [[_subButtons objectAtIndex:index] setTitle:icon forState:UIControlStateNormal];
    }
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
    for (UIButton * button in _subButtons) {
        button.backgroundColor = buttonBackgroundColor;
    }
}

- (void)setLabelColor:(UIColor *)labelColor {
    _labelColor = labelColor;
    [_subLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.textColor = labelColor;
    }];
}

- (void)setIconColor:(UIColor *)iconColor {
    _iconColor = iconColor;
    for (UIButton * button in _subButtons) {
        [button setTitleColor:iconColor forState:UIControlStateNormal];
    }
}

- (void)setLabelFont:(UIFont *)labelFont {
    _labelFont = labelFont;
    [_subLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.font = labelFont;
    }];
}

- (void)setIconFont:(UIFont *)iconFont {
    _iconFont = iconFont;
    for (BFPaperButton * button in self.subButtons) {
        [button setTitleFont:iconFont];
    }
}

- (void)setMainButtonIcon:(NSString *)mainButtonIcon {
    _mainButtonIcon = mainButtonIcon;
    if (!self.isOpen) {
        [_mainButton setTitle:mainButtonIcon forState:UIControlStateNormal];
    }
}

- (void)setMainButtonFont:(UIFont *)mainButtonFont {
    _mainButtonFont = mainButtonFont;
    [_mainButton setTitleFont:mainButtonFont];
}

- (void)setMainButtonBackgroundColor:(UIColor *)mainButtonBackgroundColor {
    _mainButtonBackgroundColor = mainButtonBackgroundColor;
    _mainButton.backgroundColor = mainButtonBackgroundColor;
}

- (void)setMainButtonIconColor:(UIColor *)mainButtonIconColor {
    _mainButtonIconColor = mainButtonIconColor;
    [_mainButton setTitleColor:mainButtonIconColor forState:UIControlStateNormal];
}

- (void)setCloseIcon:(NSString *)closeIcon {
    _closeIcon = closeIcon;
    if (self.isOpen) {
        [_mainButton setTitle:closeIcon forState:UIControlStateNormal];
    }
}

- (void)mainButtonPressed:(UIButton *)sender {
    if (!self.isOpen) {
        CGPoint originalCenter = [self convertPoint:_mainButton.center toView:nil];
        [_mainButton removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:_mainButton];
        _mainButton.center = originalCenter;
        [_mainButton setTitle:_closeIcon forState:UIControlStateNormal];
        
        _darkView.alpha = 0;
        [[UIApplication sharedApplication].keyWindow insertSubview:_darkView belowSubview:_mainButton];
        [_darkView setFrame:[UIApplication sharedApplication].keyWindow.bounds];
        
        [UIView animateWithDuration:OPEN_ANIMATION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _darkView.alpha = 0.7;
                         } completion:nil];
        
        [_subButtons enumerateObjectsUsingBlock:^(BFPaperButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[UIApplication sharedApplication].keyWindow insertSubview:obj aboveSubview:_darkView];
            obj.center = _mainButton.center;
            CGPoint pointToMoveTo = [self calculateMovePointWithIndex:(int)idx];
            [UIView animateWithDuration:OPEN_ANIMATION_DURATION
                                  delay:0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 obj.center = pointToMoveTo;
                             } completion: ^(BOOL finished) {
                                 [self addLabelForIndex:idx BelowView:obj];
                             }];
        }];
    } else {
        [_mainButton setTitle:_mainButtonIcon forState:UIControlStateNormal];
        [UIView animateWithDuration:CLOSE_ANIMATION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _darkView.alpha = 0;
                         } completion:^(BOOL finished){
                             [_darkView removeFromSuperview];
                             [_mainButton removeFromSuperview];
                             [_mainButton setFrame:self.bounds];
                             [self addSubview:_mainButton];
                         }];
        
        [_subButtons enumerateObjectsUsingBlock:^(BFPaperButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [UIView animateWithDuration:CLOSE_ANIMATION_DURATION
                                  delay:0
                 usingSpringWithDamping:0.9
                  initialSpringVelocity:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 obj.center = _mainButton.center;
                             } completion:^(BOOL finished){
                                 [obj removeFromSuperview];
                             }];
        }];

        [_subLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
    }
    
    self.isOpen = !self.isOpen;
}

- (void)addLabelForIndex:(NSInteger)index BelowView:(UIView *)view {
    UILabel * label = [_subLabels objectAtIndex:index];
    label.center = view.center;
    label.top = view.bottom + LABEL_BUTTON_CUSHION;
    [view.superview insertSubview:label aboveSubview:_darkView];
}

- (CGPoint)calculateMovePointWithIndex:(int)index {
    int quadrant = [self getQuadrantWithIndex:index];
    CGPoint movePoint = CGPointZero;
    int numButtons = (int)_buttonLabels.count;
    switch (quadrant) {
        case 1: {
            float degreesBetween = M_PI_2 / (numButtons - 1);
            float degreesForIndex = 0 - degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 2: {
            float degreesBetween = M_PI / (numButtons - 1);
            float degreesForIndex = 0 - degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 3: {
            float degreesBetween = M_PI_2 / (numButtons - 1);
            float degreesForIndex = M_PI + degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 4: {
            float degreesBetween = M_PI / (numButtons - 1);
            float degreesForIndex = degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 5: {
            float degreesBetween = 2 * M_PI / (numButtons);
            float degreesForIndex = degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 6: {
            float degreesBetween = M_PI / (numButtons - 1);
            float degreesForIndex = -M_PI_2 + degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 7: {
            float degreesBetween = M_PI_2 / (numButtons - 1);
            float degreesForIndex = degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 8: {
            float degreesBetween = M_PI / (numButtons - 1);
            float degreesForIndex = degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        case 9: {
            float degreesBetween = M_PI_2 / (numButtons - 1);
            float degreesForIndex = M_PI_2 + degreesBetween * (index);
            movePoint = CGPointMake(self.center.x + self.spreadDistance * cosf(degreesForIndex), self.center.y - self.spreadDistance * sinf(degreesForIndex));
        }
            break;
        default:
            break;
    }
    
    return movePoint;
}

- (int)getQuadrantWithIndex:(int)index {
    int xSection;
    int ySection;
    float xThird = self.superview.width / 3;
    float yThird = self.superview.height / 3;
    
    if (self.center.x < xThird) {
        xSection = 1;
    } else if (self.center.x > xThird * 2) {
        xSection = 3;
    } else {
        xSection = 2;
    }
    if (self.center.y < yThird) {
        ySection = 1;
    } else if (self.center.y > yThird * 2) {
        ySection = 3;
    } else {
        ySection = 2;
    }
    
    switch (ySection) {
        case 1:
            switch (xSection) {
                case 1:
                    return 1;
                case 2:
                    return 2;
                case 3:
                    return 3;
                default:
                    break;
            }
            break;
        case 2:
            switch (xSection) {
                case 1:
                    return 4;
                case 2:
                    return 5;
                case 3:
                    return 6;
                default:
                    break;
            }
            break;
        case 3:
            switch (xSection) {
                case 1:
                    return 7;
                case 2:
                    return 8;
                case 3:
                    return 9;
                default:
                    break;
            }
            break;
        default:
            return 3;
            break;
    }
    
    return 3; //Should never reach here (I'm using 3 because that's where I plan on having it for myself)
}

@end
