//
//  BouncyCollectionFlowLayout.h
//  Imageverse
//
//  Created by Main on 5/30/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

//How springy the collection view will appear when scrolling
typedef NS_ENUM(NSInteger, BouncyCollectionFlowLayoutSpring) {
    BouncyCollectionFlowLayoutSpringExtraSoft = 1300,
    BouncyCollectionFlowLayoutSpringSoft = 1400,
    BouncyCollectionFlowLayoutSpringDefault = 1500,
    BouncyCollectionFlowLayoutSpringFirm = 1600,
    BouncyCollectionFlowLayoutSpringExtraFirm = 1700
};

@interface BouncyCollectionFlowLayout : UICollectionViewFlowLayout

//A value of 0 means we only set animations for the current width of the collection view
//A good minimum value of this would be width of the phone screen, at least
//Making this value too big could lead to choppy behavior
@property CGFloat horizontalTilingExpansion;

//A value of 0 means we only set animations for the current height of the collection view
//A good minimum value of this would the height of the phone screen, at least
//Making this value too big could lead to choppy behavior
@property CGFloat verticalTilingExpansion;

//How springy the collection view will appear, see typdef above
@property BouncyCollectionFlowLayoutSpring springyness;

//Set this to yes before auto scrolling (causes a crash if this is set to false well auto scrolling)
@property BOOL autoScrolling;

@end
