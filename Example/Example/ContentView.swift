//
//  ContentView.swift
//  Example
//
//  Created by Kristóf Kálai on 29/10/2023.
//

import SeamCarving
import SwiftUI

struct ContentView: View {
    private static let defaultImage = UIImage(named: "example")!
    @State private var image = defaultImage

    var body: some View {
        VStack {
            imageView(Self.defaultImage)

            imageView(image)
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect(), perform: { _ in
            image = image.seamCarved
        })
    }

    private func imageView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: 360, height: 244)
    }
}

#Preview {
    ContentView()
}
