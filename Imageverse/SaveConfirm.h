//
//  SaveConfirm.h
//  Imageverse
//
//  Created by Main on 5/28/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveConfirm : UIView

+ (instancetype)newSaveConfirm;

- (void)show;

- (void)finishedSaving;

@end
