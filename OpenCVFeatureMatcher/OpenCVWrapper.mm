//
//  OpenCVWrapper.m
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

#import "OpenCVWrapper.h"

#import <opencv2/opencv.hpp>

#import "CppHelpers.hpp"

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

+ (void)computeHomography:(UIImage *)train to:(UIImage *)query {
    cout << "OpenCV: ";
    Mat trainGray = [OpenCVWrapper _matFrom:train];
    Mat queryGray = [OpenCVWrapper _matFrom:query];
    Mat homography = [OpenCVWrapper _findHomography:trainGray to:queryGray];
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

+ (bool)_validateHomography:(Mat)h {
    return CppHelpers::validateHomography(h);
}

@end
