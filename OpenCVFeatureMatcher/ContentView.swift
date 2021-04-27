//
//  ContentView.swift
//  OpenCVFeatureMatcher
//
//  Created by Edward Luo on 2021-04-26.
//

import Foundation
import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ImageCompareViewModel

    @State var pickingFirst = false
    @State var pickingSecond = false

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
            Image(uiImage: viewModel.displayedImage1)
                .resizable()
                .scaledToFit()
            Image(uiImage: viewModel.displayedImage2)
                .resizable()
                .scaledToFit()

            Divider()

            Button(action: {
                pickingFirst = true
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
            .sheet(isPresented: $pickingFirst, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.sourceImage1)
            })
            Button(action: {
                pickingSecond = true
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
            .sheet(isPresented: $pickingSecond, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $viewModel.sourceImage2)
            })
            Divider()
        }
        .padding()
    }

    var secondScreen: some View {
        VStack {
            Image(uiImage: viewModel.processedResult)
                .resizable()
                .scaledToFit()
        }
    }
}
