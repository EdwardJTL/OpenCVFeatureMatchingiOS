//
//  ImageCompareViewModel.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-27.
//

import Accelerate
import Combine
import Foundation
import SwiftUI

private func computeMatchedImages(_ image1: UIImage, _ image2: UIImage) -> UIImage {
    return OpenCVWrapper.toMatchedImageKNN(image1, and: image2)
}

private func computerHomography(_ image1: UIImage, _ image2: UIImage) -> simd_float3x3{
    return OpenCVWrapper.computeHomography(image1, to: image2)
}

class ImageCompareViewModel: ObservableObject {
    @Published var sourceImage1 = UIImage()
    @Published var sourceImage2 = UIImage()

    @Published var displayedImage1 = UIImage(systemName: "xmark.circle")!
    @Published var displayedImage2 = UIImage(systemName: "xmark.circle")!
    @Published var processedResult = UIImage(systemName: "xmark.circle")!

    @Published var homographyString = ""

    var disposables = Set<AnyCancellable>()

    init() {
        Publishers.CombineLatest($sourceImage1.dropFirst(), $sourceImage2.dropFirst())
            .receive(on: DispatchQueue.global(qos: .utility))
            .map { image1, image2 -> UIImage in
                computeMatchedImages(image1, image2)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$processedResult)
//        Publishers.CombineLatest($sourceImage1.dropFirst(), $sourceImage2.dropFirst())
//            .receive(on: DispatchQueue.global(qos: .utility))
//            .map { image1, image2 -> simd_float3x3 in
//                computerHomography(image1, image2)
//            }
//            .map { matrix -> String in
//                "\(matrix.columns.0.x)"
//            }
//            .receive(on: DispatchQueue.main)
//            .assign(to: &$homographyString)

        $sourceImage1
            .dropFirst()
            .assign(to: &$displayedImage1)
        $sourceImage2
            .dropFirst()
            .assign(to: &$displayedImage2)
    }
}
