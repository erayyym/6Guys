//
//  ContentView.swift
//  PocketLedger
//
//  Created by Chen Yang on 3/17/24.
//

import SwiftUI


struct ContentView: View {
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
            } else {
                Text("No image selected")
                    .padding() // Optional, for some spacing around the text if needed.
            }

            
            Button("Scan") {
                self.sourceType = nil
                isImagePickerPresented.toggle()
            }
            .foregroundColor(.blue)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .sheet(isPresented: $isImagePickerPresented) {
                if let sourceType = self.sourceType {
                    ImagePicker(image: $image, sourceType: sourceType)
                } else {
                    ImagePicker(image: $image, sourceType: .photoLibrary)
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
