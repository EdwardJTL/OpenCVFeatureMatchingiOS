//
//  ContentView.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var showPhotoLibrary = false
    @State var image = UIImage(named: "cat")!

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Button("Change to gray") {
                image = OpenCVWrapper.toGray(image)
            }
            Button("Change to keypoint") {
                image = OpenCVWrapper.toKeypointImage(image)
            }
            Button(action: {
                self.showPhotoLibrary.toggle()
            }, label: {
                HStack {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text("PhotoLibrary")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().foregroundColor(.blue))
            })
        }
        .padding()
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
        }
    }
}
