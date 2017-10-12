//
//  ViewController.m
//  Imageverse
//
//  Created by Main on 5/23/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+BFPaperColors.h"
#import "UIColor+BFKit.h"
#import "ViewUtils.h"
#import "BundleHolderCell.h"
#import "BundleHolder.h"
#import "BundleArray.h"
#import "BouncyCollectionFlowLayout.h"
#import "MultiButton.h"
#import "FontAwesomeFiles.h"
#import "AppDelegate.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#endif

#define BUNDLE_CUSHION 7.0
#define MAX_BUNDLES 1826

#define NUM_STARS 200
#define STAR_MIN_TWINKLE_TIME 2
#define STAR_MAX_ADDITIONAL_TIME 3

#define MULTIBUTTON_TOP_INSET 20
#define MULTIBUTTON_RIGHT_INSET 12

#define QUICK_SCROLL_NUMBER 7

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

//All of our bundles, allows for better organization
@property BundleArray * bundles;

//Collectoion view of bundleHolderCells
@property UICollectionView * bundleCollectionView;
@property BouncyCollectionFlowLayout * layout;

@property MultiButton* multiButton;

@property AppDelegate * appDelegate;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self setupBackground];
    
    self.bundles = [[BundleArray alloc] init];
    
    _layout=[[BouncyCollectionFlowLayout alloc] init];//collection view for image page
    _layout.sectionInset = UIEdgeInsetsMake(BUNDLE_CUSHION, BUNDLE_CUSHION/2, BUNDLE_CUSHION, BUNDLE_CUSHION/2);
    _layout.itemSize = CGSizeMake(self.view.width - BUNDLE_CUSHION, self.view.height - BUNDLE_CUSHION*2);
    _layout.minimumInteritemSpacing = BUNDLE_CUSHION;
    _layout.minimumLineSpacing = BUNDLE_CUSHION;
    _layout.springyness = BouncyCollectionFlowLayoutSpringExtraFirm;
    _layout.horizontalTilingExpansion = SCREEN_WIDTH;
    _layout.verticalTilingExpansion = SCREEN_HEIGHT * 4;
    
    self.bundleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:_layout];
    self.bundleCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [self.bundleCollectionView setDataSource:self];
    [self.bundleCollectionView setDelegate:self];
    [self.bundleCollectionView registerClass:[BundleHolderCell class] forCellWithReuseIdentifier:@"BundleHolderCell"];
    [self.bundleCollectionView setBackgroundColor:[UIColor clearColor]];
    self.bundleCollectionView.showsVerticalScrollIndicator = NO;
    self.bundleCollectionView.pagingEnabled = NO;
    
    [self.view addSubview:self.bundleCollectionView];
    
    NSArray * labelsArray = @[@"Most Recent", @"Oldest Viewed", @"Quick Scroll", @""];
    NSArray * iconsArray = [self setupIconsArray];
    self.multiButton = [MultiButton multiButtonWithPosition:CGPointMake(SCREEN_WIDTH * 0.82, SCREEN_HEIGHT * 0.04)
                                                   MainIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-bars"]
                                                     Labels:labelsArray
                                                      Icons:iconsArray
                                                ButtonColor:[UIColor paperColorLightBlue50]
                                                  TextColor:[UIColor paperColorBlueGray900]
                                                   TextFont:[UIFont fontAwesomeFontOfSize:26]
                                          SelectedItemBlock:^(int indexSelected) {
                                              [self multiButtonMethodsWithIndex:indexSelected];
                                          }];
    self.multiButton.top = MULTIBUTTON_TOP_INSET;
    self.multiButton.right = SCREEN_WIDTH - MULTIBUTTON_RIGHT_INSET;
    self.multiButton.labelFont = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
    self.multiButton.labelColor = [UIColor whiteColor];
    self.multiButton.closeIcon = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"];
    
    [self.view addSubview:self.multiButton];
}

-(void)setupBackground {
    /*
     UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
     imageView.image = [UIImage imageNamed:@"spaceMix.jpg"];
     imageView.contentMode = UIViewContentModeScaleToFill;
     [self.view addSubview:imageView];
     
     UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
     UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
     blurView.frame = self.view.bounds;
     [self.view addSubview:blurView];
     */
    
    CAGradientLayer * gradientBackground = [CAGradientLayer layer];
    gradientBackground.colors = [NSArray arrayWithObjects: (id)[UIColor paperColorIndigo900].CGColor, (id)[UIColor paperColorTeal900].CGColor, nil];
    gradientBackground.frame = self.view.bounds;
    [self.view.layer addSublayer:gradientBackground];
    
    for (int i = 0; i < NUM_STARS; i++) {
        CGFloat firstAlpha = (float)rand() / RAND_MAX / 2;
        CGFloat xPos = arc4random_uniform(SCREEN_WIDTH);
        CGFloat yPos = arc4random_uniform(SCREEN_HEIGHT);
        CGFloat diameter = 2 + arc4random_uniform(3);
        CGFloat secondAlpha = (float)rand() / RAND_MAX / 2 + 0.5;
        CGFloat flashTime = STAR_MIN_TWINKLE_TIME + arc4random_uniform(STAR_MAX_ADDITIONAL_TIME);
        
        CABasicAnimation * twinkle = [CABasicAnimation animationWithKeyPath:@"opacity"];
        twinkle.fromValue = [NSNumber numberWithFloat:MIN(firstAlpha, secondAlpha)];
        twinkle.toValue = [NSNumber numberWithFloat:MAX(firstAlpha, secondAlpha)];
        twinkle.duration = flashTime;
        twinkle.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        twinkle.autoreverses = YES;
        twinkle.repeatCount = INFINITY;
        
        BOOL isSquare = (arc4random_uniform(1) != 0);
        if (isSquare) {
            CALayer * star = [CALayer layer];
            star.frame = CGRectMake(xPos, yPos, diameter, diameter);
            star.backgroundColor = [UIColor whiteColor].CGColor;
            [star addAnimation:twinkle forKey:@"twinkleAnimation"];
            [self.view.layer addSublayer:star];
        } else {
            CAShapeLayer * star = [CAShapeLayer layer];
            UIBezierPath * circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(xPos, yPos, diameter, diameter)];
            [star setPath:circlePath.CGPath];
            [star setFillColor:[UIColor whiteColor].CGColor];
            [star addAnimation:twinkle forKey:@"twinkleAnimation"];
            [self.view.layer addSublayer:star];
        }
    }
}

- (NSArray<NSString *> *)setupIconsArray {
    NSString* volumeIcon = ([[NSUserDefaults standardUserDefaults] boolForKey:@"muteMusic"] ? [NSString fontAwesomeIconStringForIconIdentifier:@"fa-volume-off"] : [NSString fontAwesomeIconStringForIconIdentifier:@"fa-volume-up"]);
    return @[[NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-double-up"], [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-double-down"], [NSString fontAwesomeIconStringForIconIdentifier:@"fa-angle-down"], volumeIcon];

}

- (void)multiButtonMethodsWithIndex:(int)index {
    switch (index) {
        case 0: {
            _layout.autoScrolling = YES;
            [self.bundleCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            _layout.autoScrolling = NO;
        }
            break;
        case 1: {
            _layout.autoScrolling = YES;
            [self.bundleCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_appDelegate.oldestIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            _layout.autoScrolling = NO;
        }
            break;
        case 2: {
            NSInteger indexToMoveTo = [self.bundleCollectionView indexPathForCell:[self.bundleCollectionView visibleCells].firstObject].row + QUICK_SCROLL_NUMBER;
            _layout.autoScrolling = YES;
            [self.bundleCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexToMoveTo inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            _layout.autoScrolling = NO;
        }
            break;
        case 3: {
            if ([_appDelegate toggleSound]) {
                [self.multiButton setIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-volume-up"] ForIndex:3];
            } else {
                [self.multiButton setIcon:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-volume-off"] ForIndex:3];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDataSource / Delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX_BUNDLES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BundleHolderCell * bundleCell = (BundleHolderCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"BundleHolderCell" forIndexPath:indexPath];
    bundleCell.layer.shouldRasterize = YES;
    bundleCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    __block int index = (int)indexPath.row;
    bundleCell.bundleHolder.index = index;
    
    if (![_bundles didLoadBundleForIndex:index]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            if (![_bundles isLoadingBundleForIndex:index]) {
                
                [_bundles loadBundleForIndex:index CompletionHandler:^(NasaBundle *bundle, BOOL successful) {
                    BundleHolderCell * cell = (BundleHolderCell *)[collectionView cellForItemAtIndexPath:indexPath];
                    cell.bundleHolder.bundle = bundle;
                    if (index > _appDelegate.oldestIndex) {
                        _appDelegate.oldestIndex = index;
                    }
                    [self setupCell:cell];
                }];
            }
        });
    }

    
    return bundleCell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    BundleHolderCell * bundleCell = (BundleHolderCell *)cell;
    __block int index = (int)indexPath.row;
    
    if ([_bundles didLoadBundleForIndex:index]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            
            bundleCell.bundleHolder.bundle = [_bundles bundleForIndex:index];
            [self setupCell:bundleCell];
        });
        
    }
}

- (void)setupCell:(BundleHolderCell *)cell{
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            cell.bundleHolder.loading = NO;
            [cell.bundleHolder toggleVisuals];
        });
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //To be completed
}


@end
