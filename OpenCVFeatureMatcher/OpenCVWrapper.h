//
//  OpenCVWrapper.h
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

#import <Foundation/Foundation.h>

#import "OpenCVWrapper.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (UIImage *)toGray:(UIImage *)source;
+ (UIImage *)toKeypointImage:(UIImage *)source;
+ (UIImage *)toMatchedImage:(UIImage *)train and:(UIImage *)query;
+ (void)computeHomography:(UIImage *)train to:(UIImage *)query;
@end

NS_ASSUME_NONNULL_END
