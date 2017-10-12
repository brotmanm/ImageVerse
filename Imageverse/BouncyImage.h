//
//  BouncyImage.h
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BouncyImage : UIView

//The image contained
@property (nonatomic) UIImage* image;

//Allow the image to be bouncy upon touch, defaulted to yes
@property BOOL allowBounce;

//Static method to get a bouncy image
+ (instancetype)bouncyImageWithFrame:(CGRect)frame;

@end
