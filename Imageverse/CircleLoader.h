//
//  CircleLoader.h
//  Imageverse
//
//  Created by Main on 5/24/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLoader : UIView

//The thickness of the line
@property (nonatomic) CGFloat thickness;

//The colors to alternate between
//Use one color if just want a static color
@property (nonatomic) NSArray<UIColor *> * colors;

//Is the loader currently running through animations
@property (readonly) BOOL animated;

//Get a circle loader with the given frame
//Will default the color and thickness
+ (instancetype)circleLoaderWithFrame:(CGRect)frame;

//Get a circle loader with the given frame, colors, and thickness
+ (instancetype)circleLoaderWithFrame:(CGRect)frame Colors:(NSArray<UIColor *> *)myColors Thickness:(CGFloat)lineWidth;

/**
 * Remove the circle loader.
 */
- (void)remove;

/**
 * Animate the loader, typically called after creation.
 */
- (void)animate;

/**
 * Pause animations, the default state is paused, unless animate is called.
 */
- (void)pause;

@end
