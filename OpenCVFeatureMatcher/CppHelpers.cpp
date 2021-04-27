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

bool CppHelpers::validateHomography(cv::Mat & h) {
    const double det = h.at<double>(0,0) *  h.at<double>(1,1) - h.at<double>(1,0) *  h.at<double>(0,1);
    if (det < 0) return false;
    const double n1 = sqrt(pow(h.at<double>(0,0), 2) - pow(h.at<double>(1,0), 2));
    if (n1 > 4 || n1 < 0.1) return false;
    const double n2 = sqrt(pow(h.at<double>(0,1), 2) - pow(h.at<double>(1,1), 2));
    if (n2 > 4 || n2 < 0.1) return false;
    const double n3 = sqrt(pow(h.at<double>(2,0), 2) - pow(h.at<double>(2,1), 2));
    if (n3 > 0.002) return false;
    return true;
}
