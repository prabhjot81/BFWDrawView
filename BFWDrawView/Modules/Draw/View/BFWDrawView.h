//
//  BFWDrawView.h
//
//  Created by Tom Brodhurst-Hill on 16/10/12.
//  Copyright (c) 2012 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#else
#    define DLog(...) /* Disable Debug logging for release builds */
#endif

#import <UIKit/UIKit.h>

extern NSString * const sizesKey;
extern NSString * const sizesByPrefixKey;

IB_DESIGNABLE

@interface BFWDrawView : UIView

@property (nonatomic, copy) IBInspectable NSString* name;
@property (nonatomic, copy) IBInspectable NSString* styleKit;
@property (nonatomic, strong) IBInspectable UIColor* fillColor;

@property (nonatomic, assign) CGSize drawnSize;
@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) BOOL canDraw;

// for subclasses:

@property (nonatomic, readonly) Class styleKitClass;
@property (nonatomic, readonly) NSString *drawFrameSelectorString;
@property (nonatomic, readonly) CGRect drawFrame;
@property (nonatomic, strong) NSInvocation *drawInvocation;

#pragma mark - image output methods

- (BOOL)writeImageAtScale:(CGFloat)scale
                   toFile:(NSString*)savePath;

@end
