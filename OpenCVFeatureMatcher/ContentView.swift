//
//  ContentView.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State var image = Image("cat")

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
            Button("Change to gray") {
                let grayImage = OpenCVWrapper.toGray(UIImage(named: "cat")!)
                image = Image(uiImage: grayImage)
            }
            Button("Change to keypoint") {
                let kptImage = OpenCVWrapper.toKeypointImage(UIImage(named: "cat")!)
                image = Image(uiImage: kptImage)
            }
        }
        .padding()
    }
}
