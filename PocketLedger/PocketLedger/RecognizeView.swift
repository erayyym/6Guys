//
//  RecognizeView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/4/15.
//

import Foundation
import SwiftUI
import AVKit
import Vision
import CoreML

struct RecgnizeView: View {
    @State private var showingActionSheet = false
    @State private var isImagePickerPresented = false
    @State var image: UIImage?

    @State private var sourceType: UIImagePickerController.SourceType?
    @State private var isHiddle: Visibility = .visible
    @State var imagePredictor = ImagePredictor()
    @State var result:String = ""
    @State var predictionsToShow = 2

    var body: some View {
        NavigationView {
            VStack {
                if let image = self.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
               
                Text(result)
                Button("Scan") {
                    showingActionSheet = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.blue)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
                .actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(
                        title: Text("Choose Source"),
                        buttons: [
                            .default(Text("Camera")) { self.openCamera() },
                            .default(Text("Photo Library")) { self.openPhotoLibrary() },
                            .cancel()
                        ]
                    )
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        isHiddle = .visible
                    }
                    
                }
                
            }
            .sheet(isPresented: $isImagePickerPresented) {
                if let sourceType = self.sourceType {
                    ImagePicker(image: self.$image, sourceType: sourceType)
                        .onChange(of: image) { newImage in
                            recognizePicture()
                        }
                }
            }
        }

        .toolbar(isHiddle, for: .tabBar)

    }
    
    func openCamera() {
        sourceType = .camera
        isImagePickerPresented = true
    }
    
    func openPhotoLibrary() {
        sourceType = .photoLibrary
        isImagePickerPresented = true
    }
    func recognizePicture() {
        if let image = image {
            do {
                try self.imagePredictor.makePredictions(for: image,
                                                        completionHandler: imagePredictionHandler)
            } catch {
                result = "Vision was unable to make a prediction...\n\n\(error.localizedDescription)"
                print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
            }
        }
    }
    
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            result = "No predictions. (Check console log.)"
            return
        }

        let formattedPredictions = formatPredictions(predictions)

        let predictionString = formattedPredictions.joined(separator: "\n")
        result = predictionString
    }

    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return "\(name) - \(prediction.confidencePercentage)%"
        }

        return topPredictions
    }
}

//#Preview {
//    RecgnizeView()
//}
