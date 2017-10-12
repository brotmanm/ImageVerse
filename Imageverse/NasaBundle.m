//
//  NasaBundle.m
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "NasaBundle.h"

@interface NasaBundle ()

@property (readwrite) NSDate * bundleDate;
@property (readwrite) NSString * title;
@property (readwrite) NSString * content;
@property (readwrite) NSData * imageData;
@property (readwrite) BOOL successfullyLoaded;

@end

NSString * const NasaContentKey = @"explanation";
NSString * const NasaTitleKey = @"title";
NSString * const NasaHDUrlKey = @"hdurl";
NSString * const NasaUrlKey = @"url";

NSString * const ErrorImageName = @"error.jpg";
NSString * const EmptyTitle = @"No Title";
NSString * const EmptyContent = @"No Explanation";

@implementation NasaBundle

- (instancetype)initWithDate:(NSDate *)date {

    if (self = [super init]) {
        self.bundleDate = date;
        self.title = EmptyTitle;
        self.content = EmptyContent;
    }
    
    return self;
}

//format date to be usable with api
- (NSString *)getFormattedDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString* formattedDate = [formatter stringFromDate:self.bundleDate];
    return formattedDate;
}

#pragma mark - Data loading methods

//Get a usable URL formatted with the date and API
-(NSURL *)getURLWithDate:(NSString *)formattedDate Key:(NSString *)apiKey{
    
    //Format url correctly
    NSString* urlString = [NSString stringWithFormat:@"https://api.nasa.gov/planetary/apod?date=%@&api_key=%@", formattedDate ,apiKey];
    
    NSURL* mainURL = [NSURL URLWithString:urlString];
    return mainURL;
}

//THIS IS WHAT ACCESSES NASA'S API AND GETS THE DATA
//Get data from nasa's api using the correctly formatted api
//This method works synchronously, but we can use it in a seperate thread
//Will return nil if the accessing fails
- (NSData *)getDataFromUrl:(NSURL *)url {
    
    //get data from apod
    NSData* data = [NSData dataWithContentsOfURL:url];
    return data;
}

//Get the title from the dictionary, or the error title if it is not found
- (NSString *)getTitleFromDictionary:(NSDictionary *)dic {
    NSString * possibleTitle = [dic valueForKey:NasaTitleKey];
    
    //Make sure our title is valid
    if (possibleTitle && ![possibleTitle isEqualToString:@""]) {
        return possibleTitle;
    } else {
        return EmptyTitle;
    }
}

//Get the explanation from the dictionary, or the error explanation if it is not found
- (NSString *)getContentFromDictionary:(NSDictionary *)dic {
    NSString * possibleContent = [dic valueForKey:NasaContentKey];
    
    //Make sure our content is valid
    if (possibleContent && ![possibleContent isEqualToString:@""]) {
        return possibleContent;
    } else {
        return EmptyContent;
    }
}

//THIS FINDS THE IMAGE NASA GAVE US ONLINE
//Get data for the image using the URL found from Nasa's api
//This method works synchronously, but we can use it in a seperate thread
//Will return nil if this fails
- (NSData *)accessImageDataFromDictionary:(NSDictionary *)dic {
    NSString * url = [dic valueForKey:NasaHDUrlKey];
    
    //Check to make sure we do get a valid url
    if (!(url && url.length > 1)) {
        
        //The url may not be an HD image
        url = [dic valueForKey:NasaUrlKey];
        if (!(url && url.length > 1)) {
            return UIImagePNGRepresentation([UIImage imageNamed:ErrorImageName]);
        }
    }
    
    //If we do, get the data from the url
    return [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
}

- (BOOL)loadBundleWithApiKey:(NSString *)key {
    NSString * formattedDate = [self getFormattedDate];
    NSURL * url = [self getURLWithDate:formattedDate Key:key];
    NSData * bundleData = [self getDataFromUrl:url];
    
    if (bundleData) {
        
        //JSON serialization
        id unknownObject = [NSJSONSerialization
                            JSONObjectWithData: bundleData
                            options: 0
                            error: nil];
        
        NSDictionary * apodDictionary;
        
        //Check to see if dictionary (must be a dictionary to be valid)
        if( [unknownObject isKindOfClass: [NSDictionary class]]){
            apodDictionary = unknownObject;
            
            self.title = [self getTitleFromDictionary:apodDictionary];
            self.content = [self getContentFromDictionary:apodDictionary];
            self.imageData = [self accessImageDataFromDictionary:apodDictionary];
            
            self.successfullyLoaded = true;
            return true;
        }
    }
    
    return false;
}

//rotate wide images
-(UIImage *)rotateImageIfWide:(UIImage*)image{
    if (image.size.width > image.size.height){
        image = [UIImage imageWithCGImage:[image CGImage]
                                    scale:[image scale]
                              orientation: UIImageOrientationRight];
    }
    return image;
}

- (UIImage *)getImage {
    return [self rotateImageIfWide:[UIImage imageWithData:self.imageData]];
}

@end
