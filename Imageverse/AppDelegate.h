//
//  AppDelegate.h
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)toggleSound;
@property NSInteger oldestIndex;



@end

