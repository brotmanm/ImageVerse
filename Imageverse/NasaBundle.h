//
//  NasaBundle.h
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NasaBundle : NSObject

//The date of the bundle
@property (readonly) NSDate * bundleDate;

//Title of bundle
@property (readonly) NSString * title;

//Content of bundle
@property (readonly) NSString * content;

//Data for image of bundle
@property (readonly) NSData * imageData;

//Was the bundle successfully loaded
@property (readonly) BOOL successfullyLoaded;

/**
 * Must initialize a bundle with a date.
 * @param date the date of the bundle.
 */
- (instancetype)initWithDate:(NSDate *)date;

/**
 * Load everything into our bundle using the initialized date.
 * @param key The apiKey to load the bundle with.
 * @return whether or not the loading was sucessful.
 */
- (BOOL)loadBundleWithApiKey:(NSString *)key;

/**
 * @return a date formatted as yyyy-MM-dd.
 */
- (NSString *)getFormattedDate;

/**
 * @return a UIImage object from the current image data.
 */
- (UIImage *)getImage;

@end
