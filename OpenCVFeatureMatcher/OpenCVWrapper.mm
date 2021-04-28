//
//  OpenCVWrapper.m
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

#import "OpenCVWrapper.h"

#import <opencv2/opencv.hpp>

#import "CppHelpers.hpp"

#define RATIO 0.7

using namespace std;

using namespace cv;

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version%s", CV_VERSION];
}

#pragma mark Public

+ (UIImage *)toGray:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _grayFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toKeypointImage:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _computeFeatures:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toMatchedImage:(UIImage *)train and:(UIImage *)query {
    cout << "OpenCV: ";
    Mat trainGray = [OpenCVWrapper _matFrom:train];
    Mat queryGray = [OpenCVWrapper _matFrom:query];
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _compareFeatures:trainGray and:queryGray]];
}

+ (UIImage *)toMatchedImageKNN:(UIImage *)train and:(UIImage *)query {
    cout << "OpenCV: ";
    Mat trainGray = [OpenCVWrapper _matFrom:train];
    Mat queryGray = [OpenCVWrapper _matFrom:query];
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _compareFeaturesKNNKAZE:trainGray and:queryGray]];
}

+ (simd_float3x3)computeHomography:(UIImage *)train to:(UIImage *)query {
    cout << "OpenCV: ";
    Mat trainGray = [OpenCVWrapper _matFrom:train];
    Mat queryGray = [OpenCVWrapper _matFrom:query];
    Mat homography = [OpenCVWrapper _findHomography:trainGray to:queryGray];
    return [OpenCVWrapper _convert3x3:homography];
}

+ (simd_float3x3)computeHomographyKNNKaze:(UIImage *)train to:(UIImage *)query {
    cout << "OpenCV: ";
    Mat trainGray = [OpenCVWrapper _matFrom:train];
    Mat queryGray = [OpenCVWrapper _matFrom:query];
    Mat homography = [OpenCVWrapper _findHomographyKNNKaze:trainGray to:queryGray];
    return [OpenCVWrapper _convert3x3:homography];
}

+ (bool)validateHomography:(simd_float3x3)h {
    Mat hMat = [OpenCVWrapper _matFromSimd:h];
    return [OpenCVWrapper _validateHomography:hMat];
}

#pragma mark Private

+ (Mat)_grayFrom:(Mat)source {
    cout << "-> grayFrom ->";

    Mat result;
    cvtColor(source, result, COLOR_BGR2GRAY);

    return result;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";

    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);

    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);

    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";

    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());

    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];

    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return result;
}

+ (Mat)_computeFeatures:(Mat)image {
    cout << "-> Keypoints ->";
    cv::Ptr<ORB> orb = ORB::create();
    vector<KeyPoint> keypoints = vector<KeyPoint>();
    Mat descriptors;
    orb->detectAndCompute(image, noArray(), keypoints, descriptors);
    Mat keypointImage;
    cv::drawKeypoints(image, keypoints, keypointImage);
    cout << keypoints.size();
    return keypointImage;
}

+ (Mat)_compareFeatures:(Mat)image and:(Mat)image2 {
    cout << "-> Compare keypoints ->";
    cv::Ptr<ORB> orb = ORB::create();
    vector<KeyPoint> keypoints1 = vector<KeyPoint>();
    Mat descriptors1;
    vector<KeyPoint> keypoints2 = vector<KeyPoint>();
    Mat descriptors2;
    orb->detectAndCompute(image, noArray(), keypoints1, descriptors1);
    orb->detectAndCompute(image2, noArray(), keypoints2, descriptors2);
    cout << " image 1 keypoints count " << keypoints1.size() << " ->";
    cout << " image 2 keypoints count " << keypoints2.size() << " ->";
    cv::Ptr<BFMatcher> bf = cv::BFMatcher::create(cv::NORM_HAMMING, true);
    vector<DMatch> matches = vector<DMatch>();
    bf->match(descriptors2, descriptors1, matches);
    cout << " matches count " << matches.size() << " ->";
    sort(matches.begin(), matches.end(), CppHelpers::compareMatch);

    Mat result;
    cv::drawMatches(image, keypoints1, image2, keypoints2, matches, result);
    return result;
}

+ (Mat)_compareFeaturesKNN:(Mat) image and:(Mat)image2 {
    auto start = std::chrono::high_resolution_clock::now();
    cout << "-> Compare keypoints knn ->";
    vector<KeyPoint> keypoints1 = vector<KeyPoint>();
    Mat descriptors1;
    vector<KeyPoint> keypoints2 = vector<KeyPoint>();
    Mat descriptors2;
    cv::Ptr<ORB> orb = ORB::create();
    orb->detectAndCompute(image, noArray(), keypoints1, descriptors1);
    orb->detectAndCompute(image2, noArray(), keypoints2, descriptors2);
    cout << " image 1 keypoints count " << keypoints1.size() << " ->";
    cout << " image 2 keypoints count " << keypoints2.size() << " ->";
    cv::Ptr<BFMatcher> bf = cv::BFMatcher::create();
    vector<vector<DMatch>> matches = vector<vector<DMatch>>();
    bf->knnMatch(descriptors2, descriptors1, matches, 2);
    cout << " matches count " << matches.size() << " ->";

    vector<DMatch> goodMatches = vector<DMatch>();
    for (vector<vector<DMatch>>::iterator match = matches.begin(); match != matches.end(); ++match) {
        try {
            DMatch match0 = match->at(0);
            DMatch match1 = match->at(1);
            if (match0.distance < RATIO * match1.distance) {
                goodMatches.push_back(match0);
            }
        } catch (const std::out_of_range & ex) {
            continue;
        }
    }
    auto stop = std::chrono::high_resolution_clock::now();
    cout << "time: " << chrono::duration_cast<chrono::microseconds>(stop - start).count() << " ";
    cout << " good matches count " << goodMatches.size() << " ->";
    sort(goodMatches.begin(), goodMatches.end(), CppHelpers::compareMatch);

    Mat result;
    cv::drawMatches(image, keypoints1, image2, keypoints2, goodMatches, result);
    return result;
}

+ (Mat)_compareFeaturesKNNKAZE:(Mat) image and:(Mat)image2 {
    auto start = std::chrono::high_resolution_clock::now();
    cout << "-> Compare keypoints knn ->";
    vector<KeyPoint> keypoints1 = vector<KeyPoint>();
    Mat descriptors1;
    vector<KeyPoint> keypoints2 = vector<KeyPoint>();
    Mat descriptors2;
    cv::Ptr<AKAZE> kaze = AKAZE::create();
    kaze->detectAndCompute(image, noArray(), keypoints1, descriptors1);
    kaze->detectAndCompute(image2, noArray(), keypoints2, descriptors2);
    cout << " image 1 keypoints count " << keypoints1.size() << " ->";
    cout << " image 2 keypoints count " << keypoints2.size() << " ->";
    cv::Ptr<BFMatcher> bf = cv::BFMatcher::create();
    vector<vector<DMatch>> matches = vector<vector<DMatch>>();
    bf->knnMatch(descriptors2, descriptors1, matches, 2);
    cout << " matches count " << matches.size() << " ->";

    vector<DMatch> goodMatches = vector<DMatch>();
    for (vector<vector<DMatch>>::iterator match = matches.begin(); match != matches.end(); ++match) {
        try {
            DMatch match0 = match->at(0);
            DMatch match1 = match->at(1);
            if (match0.distance < RATIO * match1.distance) {
                goodMatches.push_back(match0);
            }
        } catch (const std::out_of_range & ex) {
            continue;
        }
    }
    auto stop = std::chrono::high_resolution_clock::now();
    cout << "time: " << chrono::duration_cast<chrono::microseconds>(stop - start).count() << " ";
    cout << " good matches count " << goodMatches.size() << " ->";
    goodMatches.resize(50);

    Mat result;
    cv::drawMatches(image, keypoints1, image2, keypoints2, goodMatches, result);
    return result;
}

+ (Mat)_findHomography:(Mat)image to:(Mat)image2 {
    cout << "-> find homography ->";
    cv::Ptr<ORB> orb = ORB::create();
    vector<KeyPoint> keypoints1 = vector<KeyPoint>();
    Mat descriptors1;
    vector<KeyPoint> keypoints2 = vector<KeyPoint>();
    Mat descriptors2;
    orb->detectAndCompute(image, noArray(), keypoints1, descriptors1);
    orb->detectAndCompute(image2, noArray(), keypoints2, descriptors2);
    cout << " image 1 keypoints count " << keypoints1.size() << " ->";
    cout << " image 2 keypoints count " << keypoints2.size() << " ->";
    cv::Ptr<BFMatcher> bf = cv::BFMatcher::create(cv::NORM_HAMMING, true);
    vector<DMatch> matches = vector<DMatch>();
    bf->match(descriptors2, descriptors1, matches);
    cout << " matches count " << matches.size() << " ->";
    sort(matches.begin(), matches.end(), CppHelpers::compareMatch);

    vector<Point2f> points1 = vector<Point2f>();
    vector<Point2f> points2 = vector<Point2f>();

    for (size_t i = 0; i < matches.size(); i++) {
        points1.push_back(keypoints1[matches[i].trainIdx].pt);
        points2.push_back(keypoints2[matches[i].queryIdx].pt);
    }

    Mat homographyMask;
    Mat homography = cv::findHomography(points1, points2, cv::RANSAC, 3, homographyMask);

    cout << "Matrix H = " << endl << homography << endl << "Matrix is valid? " << [OpenCVWrapper _validateHomography:homography] << endl;

    return homography;
}

+ (Mat)_findHomographyKNNKaze:(Mat)image to:(Mat)image2 {
    auto start = std::chrono::high_resolution_clock::now();
    cout << "-> Compare keypoints knn ->";
    vector<KeyPoint> keypoints1 = vector<KeyPoint>();
    Mat descriptors1;
    vector<KeyPoint> keypoints2 = vector<KeyPoint>();
    Mat descriptors2;
    cv::Ptr<AKAZE> kaze = AKAZE::create();
    kaze->detectAndCompute(image, noArray(), keypoints1, descriptors1);
    kaze->detectAndCompute(image2, noArray(), keypoints2, descriptors2);
    cout << " image 1 keypoints count " << keypoints1.size() << " ->";
    cout << " image 2 keypoints count " << keypoints2.size() << " ->";
    cv::Ptr<BFMatcher> bf = cv::BFMatcher::create();
    vector<vector<DMatch>> matches = vector<vector<DMatch>>();
    bf->knnMatch(descriptors2, descriptors1, matches, 2);
    cout << " matches count " << matches.size() << " ->";

    vector<DMatch> goodMatches = vector<DMatch>();
    for (vector<vector<DMatch>>::iterator match = matches.begin(); match != matches.end(); ++match) {
        try {
            DMatch match0 = match->at(0);
            DMatch match1 = match->at(1);
            if (match0.distance < RATIO * match1.distance) {
                goodMatches.push_back(match0);
            }
        } catch (const std::out_of_range & ex) {
            continue;
        }
    }
    auto stop = std::chrono::high_resolution_clock::now();
    cout << "time: " << chrono::duration_cast<chrono::microseconds>(stop - start).count() << " ";
    cout << " good matches count " << goodMatches.size() << " ->";
    goodMatches.resize(50);

    vector<Point2f> points1 = vector<Point2f>();
    vector<Point2f> points2 = vector<Point2f>();

    for (size_t i = 0; i < goodMatches.size(); i++) {
        points1.push_back(keypoints1[goodMatches[i].trainIdx].pt);
        points2.push_back(keypoints2[goodMatches[i].queryIdx].pt);
    }

    Mat homographyMask;
    Mat homography = cv::findHomography(points1, points2, cv::RANSAC, 3, homographyMask);

    cout << "Matrix H = " << endl << homography << endl << "Matrix is valid? " << [OpenCVWrapper _validateHomography:homography] << endl;

    return homography;
}

+ (bool)_validateHomography:(Mat)h {
    return CppHelpers::validateHomography(h);
}

+ (simd_float3x3)_convert3x3:(Mat)h {
    simd_float3 row0 = simd_make_float3(h.at<double>(0, 0), h.at<double>(0, 1), h.at<double>(0, 2));
    simd_float3 row1 = simd_make_float3(h.at<double>(1, 0), h.at<double>(1, 1), h.at<double>(1, 2));
    simd_float3 row2 = simd_make_float3(h.at<double>(2, 0), h.at<double>(2, 1), h.at<double>(2, 2));
    return simd_matrix_from_rows(row0, row1, row2);
}

+ (Mat)_matFromSimd:(simd_float3x3)simd {
    Mat_<double> result(3,3);
    result << simd.columns[0].x, simd.columns[0][1], simd.columns[0][2],
                simd.columns[1][0], simd.columns[1][1], simd.columns[1][2],
                simd.columns[2][0], simd.columns[2][1], simd.columns[2][2];
    return std::move(result);
}

@end
