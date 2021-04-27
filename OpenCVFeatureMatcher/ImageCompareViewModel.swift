//
//  ImageCompareViewModel.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-27.
//

import Combine
import Foundation
import SwiftUI

private func computeImages(_ image1: UIImage, _ image2: UIImage) -> UIImage {
    OpenCVWrapper.computeHomography(image1, to: image2)
    return OpenCVWrapper.toMatchedImage(image1, and: image2)
}

class ImageCompareViewModel: ObservableObject {
    @Published var sourceImage1 = UIImage()
    @Published var sourceImage2 = UIImage()

    @Published var displayedImage1 = UIImage(systemName: "xmark.circle")!
    @Published var displayedImage2 = UIImage(systemName: "xmark.circle")!
    @Published var processedResult = UIImage(systemName: "xmark.circle")!

    var disposables = Set<AnyCancellable>()

    init() {
        Publishers.CombineLatest($sourceImage1.dropFirst(), $sourceImage2.dropFirst())
            .receive(on: DispatchQueue.global(qos: .utility))
            .map { image1, image2 -> UIImage in
                computeImages(image1, image2)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$processedResult)
        $sourceImage1
            .dropFirst()
            .assign(to: &$displayedImage1)
        $sourceImage2
            .dropFirst()
            .assign(to: &$displayedImage2)
    }
}
