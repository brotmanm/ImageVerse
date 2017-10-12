//
//  MultiButton.h
//  Imageverse
//
//  Created by Main on 7/13/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Called when when a button is selected.
 * @param indexSelected The index of the selectedButton.
 */
typedef void (^MultiButtonSelectedBlock)(int indexSelected);

@interface MultiButton : UIView

/**
 * Creates a new MultiButton with the specified configuration.
 * Will automatically change the activated appearance based on position in the screen.
 * Meant to be used with some kind of icon based font, however this is not necessary
 * MAXIMUM OF 18 BUTTONS, HOWEVER WOULD RECOMMEND MUCH LESS (think 4-5 if its near a corner)
 * @param position The origin of MultiButton in its superview.
 * @param mainIcon the icon on the front of the default displayed main button
 * @param labels The text to be displayed below each button, *the size of this array equals the number of buttons on activation*, as each label corresponds to one button. If you do not want text below a button, set its corresponding label to @"".
 * @param icons The text to be displayed on top of the button, *the size of this array must equal the size of the labels array above*. If you do not want text on top of the button, set its corresponding icon to @"".
 * @param buttonColor The background color of the buttons (the color of the main button can be changed seperately.)
 * @param textColor The color of all text, will by default be the same color for icons and labels. If you would like to change this see corresponding properties below (the text color of the main button can be changed seperately.)
 * @param font The font of both the icon and label, if you would like to differentiate see properties below
 * @param selectedBlock A block that provides the index of the button selected, use this to peform various actions based on which button was pressed, likely in a switch statement.
 */
+ (instancetype)multiButtonWithPosition:(CGPoint)position
                               MainIcon:(NSString *)mainIcon
                                 Labels:(NSArray<NSString *> *)labels
                                  Icons:(NSArray<NSString *> *)icons
                            ButtonColor:(UIColor *)buttonColor
                              TextColor:(UIColor *)textColor
                               TextFont:(UIFont *)font
                      SelectedItemBlock:(MultiButtonSelectedBlock)selectedBlock;

/**
 * Change the text below the button of the given index.
 * @param index The index of the button from the label array.
 */
- (void)setLabel:(NSString *)label ForIndex:(int)index;

/**
 * Change the text in the button of the given index.
 * @param index The index of the button from the label array.
 */
- (void)setIcon:(NSString *)icon ForIndex:(int)index;

//Readonly array of labels
@property (readonly) NSMutableArray<NSString *> * buttonLabels;

//Readonly array of icons
@property (readonly) NSMutableArray<NSString *> * buttonIcons;

@property (nonatomic) UIColor * buttonBackgroundColor;

//By default these are both the same
@property (nonatomic) UIColor * labelColor;
@property (nonatomic) UIColor * iconColor;

//By default these are the same as well
@property (nonatomic) UIFont * labelFont;
@property (nonatomic) UIFont * iconFont;

//How far the buttons move away from center to center on activation
@property CGFloat spreadDistance;

//The block that is called when a button is selected
@property MultiButtonSelectedBlock blockOnSelection;

//Everything below is to customize the main button, it is defaulted to the same as the normal buttons except for its icon.
@property (nonatomic) NSString * mainButtonIcon;
@property (nonatomic) UIFont * mainButtonFont;
@property (nonatomic) UIColor * mainButtonBackgroundColor;
@property (nonatomic) UIColor * mainButtonIconColor;
@property (nonatomic) NSString * closeIcon;

@end
