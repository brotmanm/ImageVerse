//
//  BouncyCollectionFlowLayout.m
//  Imageverse
//
//  Created by Main on 5/30/17.
//  Copyright © 2017 Matt Brotman. All rights reserved.
//
//  Inspired by Ash Furrow's guide on UICollectionView + UIDynamicKit

#import "BouncyCollectionFlowLayout.h"

@interface BouncyCollectionFlowLayout () <UIScrollViewDelegate>

@property UIDynamicAnimator * animator;

@property NSMutableSet * visibleIndexPaths;

@property CGFloat currDelta;

@end

#define BOUNCY_COLLECTION_DAMPING 0.8
#define BOUNCY_COLLECTION_FREQUENCY 3.5

@implementation BouncyCollectionFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
        self.visibleIndexPaths = [NSMutableSet set];
        self.springyness = BouncyCollectionFlowLayoutSpringDefault;
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    //Set up a rect that contains all the layout attributes we want to currently have behaviours on
    //We could just do EVERY layout attribute on every cell, but that would be laggy for a lot of cells
    CGRect viewRect = CGRectMake(self.collectionView.bounds.origin.x, self.collectionView.bounds.origin.y, self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    CGRect visible = CGRectInset(viewRect, -MAX(300, fabs(self.horizontalTilingExpansion)), -MAX(300, fabs(self.verticalTilingExpansion)));
    
    //Set up an array of visible attributes, and a set of the index paths of those attributes
    NSArray<__kindof UICollectionViewLayoutAttributes *> * attrbtsInVisible = [super layoutAttributesForElementsInRect:visible];
    NSSet<NSIndexPath *> * indexPathsOfVisibleAttrbts = [NSSet setWithArray:[attrbtsInVisible valueForKey:@"indexPath"]];
    
    //Get an array of removable behaviors based if they are attached to attributes that are not visible
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(__kindof UIAttachmentBehavior  * _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        UICollectionViewLayoutAttributes * layoutAtrbs = (UICollectionViewLayoutAttributes *)obj.items.firstObject;
        return [indexPathsOfVisibleAttrbts member:layoutAtrbs.indexPath] == nil;
    }];
    NSArray<__kindof UIAttachmentBehavior *> * removableBehaviors = [self.animator.behaviors filteredArrayUsingPredicate:predicate];
    
    //For every removable behavior, remove the behavior from the animator, and remove the index path from the visible index paths
    [removableBehaviors enumerateObjectsUsingBlock:^(__kindof UIAttachmentBehavior * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.animator removeBehavior:obj];
        UICollectionViewLayoutAttributes * attrbts = (UICollectionViewLayoutAttributes *)[obj.items firstObject];
        [self.visibleIndexPaths removeObject:attrbts.indexPath];
    }];
    
    //Get an array of layout attributes to add
    //These are attributes that are in our "visible" rect, but have not had behaviors added yet
    predicate = [NSPredicate predicateWithBlock:^BOOL(__kindof UICollectionViewLayoutAttributes  * _Nullable obj, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [self.visibleIndexPaths member:obj.indexPath] == nil;
    }];
    NSArray<__kindof UICollectionViewLayoutAttributes *> * attrbtsToAdd = [attrbtsInVisible filteredArrayUsingPredicate:predicate];
    
    //Everything above was just to make sure a reasonable number of attributes have behaviors, to prevent lag
    //Now that we know which attributes we want behaviors added to, we can setup and add behaviors to those attributes
    //This allows us to animate attributes coming into the view of our "visible" rect
    CGPoint touchPoint = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [attrbtsToAdd enumerateObjectsUsingBlock:^(__kindof UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint currCenter = obj.center;
        
        //Create an attachment behavior in which the attribute is attached to its original center (sets up animation)
        //Then setup the behavior using constants defined above
        UIAttachmentBehavior * springBehavior = [[UIAttachmentBehavior alloc] initWithItem:obj attachedToAnchor:currCenter];
        //springBehavior.length = 0;
        springBehavior.damping = BOUNCY_COLLECTION_DAMPING;
        springBehavior.frequency = BOUNCY_COLLECTION_FREQUENCY;
        springBehavior.length = 1.0;

        //Adjust the item's center based on where the user touched the scroll view
        //Appears to move more closer to touch using this
        if (!CGPointEqualToPoint(CGPointZero, touchPoint)) {
            CGFloat verticalTouchDifference = fabs(touchPoint.y - springBehavior.anchorPoint.y);
            CGFloat scrollResistance = (verticalTouchDifference) / _springyness;
            
            //Make sure the center is moved in the right direction based on how the user scrolled
            if (self.currDelta < 0) {
                currCenter.y += MAX(self.currDelta, self.currDelta * scrollResistance);
            }
            else {
                currCenter.y += MIN(self.currDelta, self.currDelta * scrollResistance);
            }
            obj.center = currCenter;
        }
        
        //Add animation to animator
        [self.animator addBehavior:springBehavior];
        
        //Add the index path of the object to visible index paths (so we know what already has and needs behaviors)
        [self.visibleIndexPaths addObject:obj.indexPath];
        
        //Have lower indexed objects appear above higher indexed objects
        obj.zIndex = obj.indexPath.row;
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.animator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_autoScrolling) {
        return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
    } else {
        return [super layoutAttributesForItemAtIndexPath:indexPath];
    }
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //Find out how far the user has scrolled when updating
    UIScrollView * scrollViewInsideCollectionView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollViewInsideCollectionView.bounds.origin.y;
    self.currDelta = delta;
    
    //Update the beviors using the current attributes
    CGPoint touchPoint = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [self.animator.behaviors enumerateObjectsUsingBlock:^(__kindof UIAttachmentBehavior * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UICollectionViewLayoutAttributes * item = (UICollectionViewLayoutAttributes *)obj.items.firstObject;
        
        //Setup bouncyness based on distance from touch
        CGFloat verticalTouchDifference = fabs(touchPoint.y - obj.anchorPoint.y);
        CGFloat scrollResistance = (verticalTouchDifference) / _springyness;
        
        //Update the center of the item based on its distance from the touch
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta * scrollResistance);
        }
        else {
            center.y += MIN(delta, delta * scrollResistance);
        }
        item.center = center;
        
        [self.animator updateItemUsingCurrentState:item];
    }];
    
    //The dynamic animator AUTOMATICALLY invalidates layouts for bounds change
    return NO;
}

@end
