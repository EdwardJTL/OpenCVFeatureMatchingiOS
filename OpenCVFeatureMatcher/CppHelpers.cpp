//
//  CppHelpers.cpp
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-27.
//

#include "CppHelpers.hpp"

bool CppHelpers::compareMatch(cv::DMatch & i, cv::DMatch & j) {
    return i.distance < j.distance;
}
