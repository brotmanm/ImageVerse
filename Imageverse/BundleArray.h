//
//  BundleArray.h
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NasaBundle.h"

@interface BundleArray : NSObject

//This is designed mainly to create easy asynchronous loading

//size of the bundle array
@property (readonly) int size;

/**
 * Converts the given index into a date.
 * 0 = today, 1 = yesterday, 2 = two days ago, etc.
 * @param index the number of days ago we want the bundle for.
 * @return the data of index days ago.
 */
- (NSDate *)dateForIndex:(int)index;

/**
 * Gets the bundle at the given index, or returns nil if no bundle is found.
 * @param index the index to search at.
 * @return bundle at the index, or nil.
 */
- (NasaBundle *)bundleForIndex:(int)index;

/**
 * Load the bundle at the given index.
 * This is useful here because this will check if we've already loaded or are currently loading it.
 * Will create and load a new bundle at the index if one didnt exist there.
 * Will do nothing if the bundle has already been loaded.
 * @param index the index to load the bundle at.
 * @param completionHandler block to execute upon completion.
 */
- (void)loadBundleForIndex:(int)index CompletionHandler:(void (^)(NasaBundle * bundle, BOOL successful))completionHandler;

/**
 * Allows the user to ask whether or not a bundle at the given index was loaded.
 * Always returns false if no bundle exists at the index.
 * @param index the index to check.
 * @return If the bundle at the given index was already loaded.
 */
- (BOOL)didLoadBundleForIndex:(int)index;

/**
 * Allows the user to ask whether or not a bundle at the given index is being loaded.
 * Always returns false if no bundle exists at the index.
 * @param index the index to check.
 * @return If the bundle at the given index is being loaded.
 */
- (BOOL)isLoadingBundleForIndex:(int)index;

@end
