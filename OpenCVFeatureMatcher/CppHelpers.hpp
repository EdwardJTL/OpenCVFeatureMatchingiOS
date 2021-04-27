//
//  CppHelpers.hpp
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-27.
//

#ifndef CppHelpers_hpp
#define CppHelpers_hpp

#include <stdio.h>
#include <vector>

#include <opencv2/opencv.hpp>

namespace CppHelpers {
bool compareMatch(cv::DMatch & i, cv::DMatch & j);
}

#endif /* CppHelpers_hpp */
