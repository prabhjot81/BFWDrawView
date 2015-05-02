//
//  BFWDrawExport.m
//
//  Created by Tom Brodhurst-Hill on 23/03/2015.
//  Copyright (c) 2015 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

#import "BFWDrawExport.h"
#import "NSObject+BFWStyleKit.h"
#import "BFWAnimationView.h"
#import "NSString+BFW.h"

@implementation NSArray (BFW)

- (NSArray *)arrayByReplacingFirstObjectWithReplaceDict:(NSDictionary *)replaceDict
{
    NSArray *replacedArray = self;
    for (NSString *oldPrefix in replaceDict) {
        NSString *firstString = [[self firstObject] lowercaseString];
        if ([firstString isEqualToString:oldPrefix]) {
            NSString *newPrefix = replaceDict[oldPrefix];
            NSMutableArray *wordsMutable = [replacedArray mutableCopy];
            wordsMutable[0] = newPrefix;
            replacedArray = [wordsMutable copy];
        }
    }
    return replacedArray;
}

@end

@implementation NSString (BFWDrawExport)

- (NSString *)androidFileName
{
    NSArray *words = [[self camelCaseToWords] componentsSeparatedByString:@" "];
    NSDictionary *replacePrefixDict = @{@"button" : @"btn",
                                        @"icon" : @"ic"};
    words = [words arrayByReplacingFirstObjectWithReplaceDict:replacePrefixDict];
    NSString *fileName = [[words componentsJoinedByString:@"_"] lowercaseString];
    return fileName;
}

@end

static NSString * const baseKey = @"base";
static NSString * const sizeKey = @"size";
static NSString * const tintColorKey = @"tintColor";
static NSString * const derivedKey = @"derived";
static NSString * const animationKey = @"animation";

@implementation BFWDrawExport

+ (void)writeAllImagesToDirectory:(NSString *)directoryPath
                        styleKits:(NSArray *)styleKitArray
                    pathScaleDict:(NSDictionary *)pathScaleDict
                        tintColor:(UIColor *)tintColor
                          android:(BOOL)isAndroid
                         duration:(CGFloat)duration
                  framesPerSecond:(CGFloat)framesPerSecond
{
    NSMutableSet *usedFileNames = [[NSMutableSet alloc] init];
    for (NSString *styleKit in styleKitArray) {
        Class styleKitClass = NSClassFromString(styleKit);
        NSDictionary *parameterDict = [styleKitClass parameterDict];
        NSDictionary *drawParameterDict = [styleKitClass drawParameterDict];
        NSArray *drawingNames = drawParameterDict.allKeys;
        for (NSString *drawingName in drawingNames) {
            NSArray *parameters = drawParameterDict[drawingName];
            BOOL isAnimation = [parameters containsObject:@"animation"];
            Class class = isAnimation ? [BFWAnimationView class] : [BFWDrawView class];
            BFWAnimationView *drawView = [[class alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
            drawView.name = drawingName;
            drawView.styleKit = styleKit;
            CGSize size = drawView.drawnSize;
            if (CGSizeEqualToSize(size, CGSizeZero)) {
                DLog(@"missing size for drawing: %@", drawingName);
            }
            else {
                drawView.frame = CGRectMake(0, 0, size.width, size.height);
                drawView.tintColor = tintColor;
                NSString *fileName = isAndroid ? [drawingName androidFileName] : drawingName;
                if ([usedFileNames containsObject:fileName]) {
                    DLog(@"**** warning: attempted to write over existing file: %@", fileName);
                }
                else {
                    [usedFileNames addObject:fileName];
                    [self writeImagesFromDrawView:drawView
                                      toDirectory:directoryPath
                                    pathScaleDict:pathScaleDict
                                             size:size
                                         fileName:fileName
                                         duration:duration
                                  framesPerSecond:framesPerSecond];
                }
            }
        }
        // TODO: refactor for above and below to to call a common method
        for (NSString *drawingName in parameterDict[derivedKey]) {
            NSDictionary *derivedDict = parameterDict[derivedKey][drawingName];
            NSString *baseName = derivedDict[baseKey];
            NSString *sizeString = derivedDict[sizeKey] ? derivedDict[sizeKey] : parameterDict[sizesKey][baseName];
            if (sizeString) {
                CGSize size = CGSizeFromString(sizeString);
                UIColor *useTintColor = tintColor;
                NSString *tintColorString = derivedDict[tintColorKey];
                if (tintColorString) {
                    useTintColor = [styleKitClass colorWithName:tintColorString];
                }
                if (!CGSizeEqualToSize(size, CGSizeZero)) {
                    NSArray *parameters = drawParameterDict[drawingName];
                    BOOL isAnimation = [parameters containsObject:@"animation"];
                    Class class = isAnimation ? [BFWAnimationView class] : [BFWDrawView class];
                    BFWAnimationView *drawView = [[class alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                    drawView.name = baseName;
                    drawView.styleKit = styleKit;
                    drawView.tintColor = useTintColor;
                    NSNumber *animationNumber = derivedDict[animationKey];
                    if (animationNumber) {
                        drawView.animation = animationNumber.doubleValue;
                    }
                    drawView.contentMode = UIViewContentModeScaleAspectFit;
                    NSString *fileName = isAndroid ? [drawingName androidFileName] : drawingName;
                    [self writeImagesFromDrawView:drawView
                                      toDirectory:directoryPath
                                    pathScaleDict:pathScaleDict
                                             size:size
                                         fileName:fileName
                                         duration:duration
                                  framesPerSecond:framesPerSecond];
                }
            }
        }
    }
}

+ (void)writeImagesFromDrawView:(BFWDrawView *)drawView
                    toDirectory:(NSString *)directoryPath
                  pathScaleDict:(NSDictionary *)pathScaleDict
                           size:(CGSize)size
                       fileName:(NSString *)fileName
                       duration:(CGFloat)duration
                framesPerSecond:(CGFloat)framesPerSecond
{
    for (NSString *path in pathScaleDict) {
        NSNumber *scaleNumber = pathScaleDict[path];
        CGFloat scale = [scaleNumber floatValue];
        NSString *relativePath;
        if ([path containsString:@"%@"]) {
            relativePath = [NSString stringWithFormat:path, fileName];
        }
        else {
            relativePath = [path stringByAppendingPathComponent:fileName];
        }
        NSString *filePath = [directoryPath stringByAppendingPathComponent:relativePath];
        filePath = [filePath stringByAppendingPathExtension:@"png"];
        BOOL success = NO;
        if ([drawView isKindOfClass:[BFWAnimationView class]]) {
            BFWAnimationView *animationView = (BFWAnimationView *)drawView;
            if (duration) {
                animationView.duration = duration;
            }
            animationView.framesPerSecond = framesPerSecond;
            success = [animationView writeImagesAtScale:scale
                                                 toFile:filePath];
        }
        else {
            success = [drawView writeImageAtScale:scale
                                           toFile:filePath];
        }
        if (!success) {
            NSLog(@"failed to write %@", relativePath);
        }
    }
}

+ (void)exportForAndroidToDirectory:(NSString *)directory
                          styleKits:(NSArray *)styleKits
                      pathScaleDict:(NSDictionary *)pathScaleDict
                          tintColor:(UIColor *)tintColor
                           duration:(CGFloat)duration
                    framesPerSecond:(CGFloat)framesPerSecond
{
    DLog(@"writing images to %@", directory);
    [self writeAllImagesToDirectory:directory
                          styleKits:styleKits
                      pathScaleDict:pathScaleDict
                          tintColor:tintColor
                            android:YES
                           duration:duration
                    framesPerSecond:framesPerSecond];
    /// Note: currently exports colors only from the first styleKit
    NSString *colorsXmlString = [NSClassFromString(styleKits.firstObject) colorsXmlString];
    NSString *colorsFile = [directory stringByAppendingPathComponent:@"paintcode_colors.xml"];
    [colorsXmlString writeToFile:colorsFile
                      atomically:YES
                        encoding:NSStringEncodingConversionAllowLossy
                           error:nil];
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    return documentsPath;
}

+ (void)exportForAndroidToDocumentsStyleKits:(NSArray *)styleKits
                               pathScaleDict:(NSDictionary *)pathScaleDict
                                   tintColor:(UIColor *)tintColor
                                    duration:(CGFloat)duration
                             framesPerSecond:(CGFloat)framesPerSecond
{
    NSString *directory = [[self documentsDirectoryPath] stringByAppendingPathComponent:@"android_drawables"];
    [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
    [self exportForAndroidToDirectory:directory
                            styleKits:styleKits
                        pathScaleDict:pathScaleDict
                            tintColor:tintColor
                             duration:(CGFloat)duration
                      framesPerSecond:framesPerSecond];
}

@end
