//
//  BundleArray.m
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "BundleArray.h"

@interface BundleArray ()

//size of bundle array
@property (readwrite) int size;

//set of all indeces filled with an initialized bundle
@property NSMutableIndexSet * initializedBundles;

//maps dates (in their string form) to the corresponding bundle
@property NSMutableDictionary * dateToBundle;

//Set of integers representing loaded bundles
@property NSMutableIndexSet * loaded;

//Set of integers representing loading bundles (acts somewhat like a bloom filter.)
@property NSMutableIndexSet * loading;

@end

NSString * const ApiKey = @"6U6yyFWpsIQ43os08oZGAKoN5ZfLyXDPzqwHzvff";
int const DelayToAllowReloading = 3;

@implementation BundleArray

- (instancetype)init {
    if (self = [super init]) {
        self.initializedBundles = [[NSMutableIndexSet alloc] init];
        self.dateToBundle = [[NSMutableDictionary alloc] init];
        self.loaded = [[NSMutableIndexSet alloc] init];
        self.loading = [[NSMutableIndexSet alloc] init];
    }
    
    return self;
}

- (NSDate *)dateForIndex:(int)index {
    return [[NSDate date] dateByAddingTimeInterval:index * 60 * 60 * 24 * -1];
}

- (NSString *)stringFromIndex:(int)index {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [self dateForIndex:index];
    NSString * formattedDate = [formatter stringFromDate:date];
    return formattedDate;
}

- (NasaBundle *)bundleForIndex:(int)index {
    if ([self hasBundleForIndex:index]) {
        return [self.dateToBundle objectForKey:[self stringFromIndex:index]];
    } else {
        return nil;
    }
}

- (BOOL)hasBundleForIndex:(int)index {
    return [self.initializedBundles containsIndex:index];
}

- (NasaBundle *)createBundleForIndex:(int)index {
    NasaBundle * bundle = [[NasaBundle alloc] initWithDate:[self dateForIndex:index]];
    [self.dateToBundle setValue:bundle forKey:[self stringFromIndex:index]];
    [self.initializedBundles addIndex:index];
    self.size += 1;
    return bundle;
}

- (void)loadBundleForIndex:(int)index CompletionHandler:(void (^)(NasaBundle * bundle, BOOL successful))completionHandler; {
    
    [self.loading addIndex:index];
    
    NasaBundle * bundle = [self createBundleForIndex:index];
    BOOL success = NO;
    
    if ([bundle loadBundleWithApiKey:ApiKey]) {
        [_loaded addIndex:index];
        success = YES;
    }
    
    completionHandler(bundle, success);
    [self.loading removeIndex:index];
}

- (BOOL)didLoadBundleForIndex:(int)index {
    return [_loaded containsIndex:index];
}

-(BOOL)isLoadingBundleForIndex:(int)index {
    return [_loading containsIndex:index];
}

@end
