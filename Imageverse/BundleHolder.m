//
//  BundleHolder.m
//  Imageverse
//
//  Created by Main on 5/24/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "BundleHolder.h"
#import "BouncyImage.h"
#import "ViewUtils.h"
#import "CircleLoader.h"
#import "UIColor+BFPaperColors.h"
#import "UIColor+BFKit.h"
#import "FTPopOverMenu.h"
#import "FontAwesomeFiles.h"
#import "SaveConfirm.h"

@interface BundleHolder ()

@property BouncyImage * loaderImage;
@property BouncyImage * bouncyImage;
@property UILabel * titleLabel;
@property UILabel * contentPreviewLabel;
@property UIButton * menuButton;

@property CircleLoader * mainLoader;
@property CircleLoader * textLoader;

@property BOOL isVisible;

@end

#define BUNDLE_MENU_WIDTH 60
#define BUNDLE_CONTENT_FONT @"AvenirNext-Regular"
#define BUNDLE_TITLE_FONT @"AvenirNext-Medium"

#define UIViewParentController(__view) ({ \
UIResponder *__responder = __view; \
while ([__responder isKindOfClass:[UIView class]]) \
__responder = [__responder nextResponder]; \
(UIViewController *)__responder; \
})

@implementation BundleHolder

+ (instancetype)bundleHolderWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    //Blur
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.bounds;
    blurView.backgroundColor = [UIColor colorWithColor:[UIColor paperColorGray900] alpha:0.5];
    [self addSubview:blurView];
    
    //Bouncy image to hold a loader
    self.loaderImage = [BouncyImage bouncyImageWithFrame:[self setupImageFrame]];

    //Circle loader for image
    self.mainLoader = [CircleLoader circleLoaderWithFrame:CGRectMake(0, 0, 100, 100) Colors:[self setupColorArray] Thickness:6];
    [self.loaderImage addSubview:self.mainLoader];
    self.mainLoader.center = self.loaderImage.center;
    [self addSubview:self.loaderImage];
    
    //Bouncy image for the image
    self.bouncyImage = [BouncyImage bouncyImageWithFrame:[self setupImageFrame]];
    
    //Title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.loaderImage.bottom + 3, self.width - 10, 25)];
    //[self.titleLabel setFont:[UIFont fontWithName:BUNDLE_TITLE_FONT size:17]];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor paperColorBlue50];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 1;
    NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@""];
    self.titleLabel.attributedText = titleString;
    self.titleLabel.adjustsFontSizeToFitWidth=YES;
    self.titleLabel.minimumScaleFactor = 0.5;
    [self addSubview:self.titleLabel];
    
    //Content label
    self.contentPreviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.titleLabel.bottom - 7, self.width - 10 - BUNDLE_MENU_WIDTH, 80)];
    //[self.contentPreviewLabel setFont:[UIFont fontWithName:BUNDLE_CONTENT_FONT size:16]];
    self.contentPreviewLabel.backgroundColor = [UIColor clearColor];
    self.contentPreviewLabel.textColor = [UIColor paperColorBlue50];
    self.contentPreviewLabel.numberOfLines = 3;
    self.contentPreviewLabel.textAlignment = NSTextAlignmentJustified;
    NSMutableAttributedString * contentString = [[NSMutableAttributedString alloc] initWithString:@""];
    self.contentPreviewLabel.attributedText = contentString;
    [self addSubview:self.contentPreviewLabel];
    
    //Loader to show that text is loading
    self.textLoader = [CircleLoader circleLoaderWithFrame:CGRectMake(0, 0, 40, 40) Colors:@[[UIColor paperColorBlue50]] Thickness:3];
    self.textLoader.center = CGPointMake(self.width / 2, self.loaderImage.bottom + 0.15 * self.height / 2);
    [self addSubview:self.textLoader];
    
    //Start loading
    [self.mainLoader animate];
    [self.textLoader animate];
    _loading = YES;
    _isVisible = NO;
    
    //Menu Button
    self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(_contentPreviewLabel.right, self.titleLabel.bottom, BUNDLE_MENU_WIDTH, BUNDLE_MENU_WIDTH)];
    self.menuButton.center = _contentPreviewLabel.center;
    self.menuButton.left = _contentPreviewLabel.right;
    self.menuButton.showsTouchWhenHighlighted = YES;
    [self.menuButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:38]];
    [self.menuButton setTitleColor:[UIColor paperColorBlueGray100] forState:UIControlStateNormal];
    [self.menuButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-ellipsis-v"] forState:UIControlStateNormal];
    [self.menuButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.menuButton setBackgroundColor:[UIColor clearColor]];
    [self.menuButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    _menuButton.hidden = YES;
    [self addSubview:_menuButton];
}

- (NSArray<UIColor *> *)setupColorArray {
    return @[[UIColor paperColorCyanA400], [UIColor paperColorTealA400], [UIColor paperColorDeepPurpleA400], [UIColor paperColorBlueA400], [UIColor paperColorPurpleA400], [UIColor paperColorPinkA400]];
}

- (CGRect)setupImageFrame {
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 0.85);
}

//scale the image to fit in the size without distorting it
//Saves A LOT of time when we have to load our image to the screen on the main thread
- (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size {
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setBundle:(NasaBundle *)bundle {
    _bundle = bundle;
    self.bouncyImage.image = [self imageWithImage:bundle.getImage scaledToFillSize:self.bouncyImage.size];
    if (!self.bouncyImage.image) {
        self.bouncyImage.image = [UIImage imageNamed:@"error.jpg"];
    }
}

- (void)toggleVisuals {
    if (_loading) {
        if (_isVisible) {
            [self.bouncyImage removeFromSuperview];
            [self addSubview:self.loaderImage];
            [self.mainLoader animate];
            [self.textLoader animate];
            _isVisible = NO;
            
            NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:@""];
            self.titleLabel.attributedText = titleString;
            
            NSMutableAttributedString * contentString = [[NSMutableAttributedString alloc] initWithString:@""];
            self.contentPreviewLabel.attributedText = contentString;
            
            _menuButton.hidden = YES;
        }
    } else if (_bundle) {
        if (!_isVisible) {
            [self.mainLoader pause];
            [self.textLoader pause];
            [self.loaderImage removeFromSuperview];
            [self addSubview:self.bouncyImage];
            _isVisible = YES;
            
            NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:self.bundle.title];
            [titleString setAttributes:@{ NSFontAttributeName: [UIFont fontWithName:BUNDLE_TITLE_FONT size:18]} range:NSMakeRange(0, self.bundle.title.length)];
            self.titleLabel.attributedText = titleString;
            
            NSMutableAttributedString * contentString = [[NSMutableAttributedString alloc] initWithString:self.bundle.content];
            NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            [contentString setAttributes:@{ NSFontAttributeName: [UIFont fontWithName:BUNDLE_CONTENT_FONT size:16], NSParagraphStyleAttributeName: paragraphStyle} range:NSMakeRange(0, self.bundle.content.length)];
            self.contentPreviewLabel.attributedText = contentString;
            
            _menuButton.hidden = NO;
        }
    }
}

- (void)showMenu:(UIButton *)button {
    if (!_bundle.successfullyLoaded) {
        return;
    }
    FTPopOverMenuConfiguration * config = [FTPopOverMenuConfiguration defaultConfiguration];
    config.borderWidth = 0.0f;
    config.menuRowHeight = 50.0f;
    config.menuWidth = 140.0f;
    config.borderColor = [UIColor paperColorBlue50];
    config.textColor = [UIColor paperColorBlue50];
    config.tintColor = [UIColor paperColorBlueGray900];
    
    NSArray * imageArray = @[
                             [UIImage imageWithIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-download"] backgroundColor:[UIColor clearColor] iconColor:[UIColor paperColorBlue50] fontSize:22],
                             [UIImage imageWithIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-external-link-square"] backgroundColor:[UIColor clearColor] iconColor:[UIColor paperColorBlue50] fontSize:22],
                             [UIImage imageWithIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-picture-o"] backgroundColor:[UIColor clearColor] iconColor:[UIColor paperColorBlue50] fontSize:22]];
    [FTPopOverMenu showForSender:button
                   withMenuArray:@[@"Save to Photos", @"Export Image", @"Full Screen"]
                      imageArray:imageArray
                       doneBlock:^(NSInteger selectedIndex) {
                           switch (selectedIndex) {
                               case 0:
                                   [self saveToPhotos];
                                   break;
                               case 1:
                                   [self showActivityVC];
                                   break;
                               case 2:
                                   NSLog(@"Full Screen (not finished yet)");
                                   break;
                               default:
                                   break;
                           }
                       } dismissBlock:^{
                           //Nothing to do on dismiss
                       }];
}

- (void)saveToPhotos {
    NasaBundle * bundleToSave = self.bundle;
    UIImage * image = [UIImage imageWithData:self.bundle.imageData];
    
    if (image) {
        SaveConfirm * saveConfirm = [SaveConfirm newSaveConfirm];
        [saveConfirm show];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:bundleToSave.imageData], nil, nil, (__bridge void * _Nullable)(bundleToSave.title));
            
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                [saveConfirm finishedSaving];
            });
        });
    }
}

- (void)showActivityVC {
    UIImage * image = [UIImage imageWithData:self.bundle.imageData];
    if (image) {
        UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
        
        NSArray<UIActivityType> * exclude = @[UIActivityTypePostToWeibo, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        activityController.excludedActivityTypes = exclude;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIViewParentController(self) presentViewController:activityController animated:YES completion:nil];
        }];
    }
}

@end
