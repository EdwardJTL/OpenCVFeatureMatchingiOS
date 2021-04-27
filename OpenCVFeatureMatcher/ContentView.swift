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
    @State var image = UIImage()
    @State var image2 = UIImage()

    @State var pickingFirst = true

    var body: some View {
        NavigationView {
            VStack {
                firstScreen
                NavigationLink(
                    destination: secondScreen,
                    label: {
                        Text("Process images")
                    })
            }
        }
    }

    var firstScreen: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            Image(uiImage: image2)
                .resizable()
                .scaledToFit()

            Divider()

            Button(action: {
                pickingFirst = true
                self.showPhotoLibrary.toggle()
            }, label: {
                HStack {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text("Pick top image")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().foregroundColor(.blue))
            })
            Button(action: {
                pickingFirst = false
                self.showPhotoLibrary.toggle()
            }, label: {
                HStack {
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                    Text("Pick bottom image")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding()
                .background(Capsule().foregroundColor(.blue))
            })
            Divider()
        }
        .padding()
        .sheet(isPresented: $showPhotoLibrary) {
            if pickingFirst {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image)
            } else {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $image2)
            }
        }
    }

    var secondScreen: some View {
        VStack {
//            HStack {
//                ProcessedImageView(image)
//                ProcessedImageView(image2)
//            }
            CompareImagesView(source: image, query: image2)
        }
    }
}

struct ProcessedImageView: View {
    @State var image: UIImage

    init(_ image: UIImage) {
        self._image = State<UIImage>(initialValue: image)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .onAppear(perform: {
                image = OpenCVWrapper.toKeypointImage(image)
            })
    }
}


struct CompareImagesView: View {
    @State var image = UIImage()
    @State var source: UIImage
    @State var query: UIImage

    init(source: UIImage, query: UIImage) {
        self._source = State<UIImage>(initialValue: source)
        self._query = State<UIImage>(initialValue: query)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .onAppear(perform: {
                image = OpenCVWrapper.toMatchedImage(source, and: query)
            })

    }
}
