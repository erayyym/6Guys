
import SwiftUI
import AVKit
import Vision
import CoreML

class ImageRecognizer: ObservableObject {
    @Published var result: String = ""
    private let imagePredictor = ImagePredictor()
    @State var predictionsToShow = 1

    func recognizePicture(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image, completionHandler: imagePredictionHandler)
        } catch {
            result = "Vision was unable to make a prediction...\n\n\(error.localizedDescription)"
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
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
        print(result)
    }


    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification

            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

//            return "\(name) - \(prediction.confidencePercentage)%"
            return "\(name)"
        }

        return topPredictions
    }
}
