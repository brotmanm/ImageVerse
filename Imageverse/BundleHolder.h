//
//  BundleHolder.h
//  Imageverse
//
//  Created by Main on 5/24/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NasaBundle.h"

@interface BundleHolder : UIView

//Static method to get a new bundle holder with the given frame
+ (instancetype)bundleHolderWithFrame:(CGRect)frame;

//The bundle to hold.
@property (nonatomic) NasaBundle * bundle;

//Determines whether the loaders are visible and everything else is hidden
@property BOOL loading;

//Toggles visuals based on if the holder is in loading mode or not
- (void)toggleVisuals;

@property int index;

@end
