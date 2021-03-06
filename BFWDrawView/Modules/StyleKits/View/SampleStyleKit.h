//
//  SampleStyleKit.h
//  BFWDrawView
//
//  Created by Tom Brodhurst-Hill on 21/07/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface SampleStyleKit : NSObject

// Colors
+ (UIColor*)translucentBlack;
+ (UIColor*)buttonHighlightedColor;
+ (UIColor*)baseLightColor;
+ (UIColor*)baseColor;
+ (UIColor*)buttonColor;

// Shadows
+ (NSShadow*)buttonShadow;
+ (NSShadow*)buttonShadowHighlighted;

// Drawing Methods
+ (void)drawPacManWithFrame: (CGRect)frame animation: (CGFloat)animation;
+ (void)drawBathroomWithFrame: (CGRect)frame;
+ (void)drawFrontDoor;
+ (void)drawButtonWithFrame: (CGRect)frame;
+ (void)drawButtonHighlightedWithFrame: (CGRect)frame;
+ (void)drawIconPacManWithFrame: (CGRect)frame tintColor: (UIColor*)tintColor;
+ (void)drawIconGhostWithFrame: (CGRect)frame tintColor: (UIColor*)tintColor;

@end



@interface NSShadow (PaintCodeAdditions)

+ (instancetype)shadowWithColor: (UIColor*)color offset: (CGSize)offset blurRadius: (CGFloat)blurRadius;
- (void)set;

@end
