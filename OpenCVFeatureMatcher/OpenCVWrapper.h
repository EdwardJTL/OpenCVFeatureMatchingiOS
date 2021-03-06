//
//  OpenCVWrapper.h
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

#import <Foundation/Foundation.h>

#import <Accelerate/Accelerate.h>

#import <simd/simd.h>

#import "OpenCVWrapper.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (UIImage *)toGray:(UIImage *)source;
+ (UIImage *)toKeypointImage:(UIImage *)source;
+ (UIImage *)toMatchedImage:(UIImage *)train and:(UIImage *)query;
+ (UIImage *)toMatchedImageKNN:(UIImage *)train and:(UIImage *)query;
+ (simd_float3x3)computeHomography:(UIImage *)train to:(UIImage *)query;
+ (simd_float3x3)computeHomographyKNNKaze:(UIImage *)train to:(UIImage *)query;
+ (bool)validateHomography:(simd_float3x3)h;
@end

NS_ASSUME_NONNULL_END
