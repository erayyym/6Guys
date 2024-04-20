//
//  ScanView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//


import SwiftUI
import Vision
import Combine
import Speech

struct ScanView: View {
    @Environment(\.presentationMode) var presentationMode

    
    @State private var recepit: Recepit = Recepit()
    @State private var receiptItems: [RecepitItem] = []
    @State private var names: [String] = []
    @State private var recognizedText = ""
    @State var image: UIImage?
    @State var recognizeImage: UIImage?
    @State private var showingActionSheet = false
    @State private var showingSubmitView = false
    private let randomUUID = UUID()
    
    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    @State private var recognizedTexts = [String]()
    @State private var annotations = [Annotation]()
    @State private var editingIndex: Int?
    @State private var isEditingName: Bool = false
    @State private var isEditingPrice: Bool = false
    @State var answerlist: [String] = []
    
    @State private var isRecording: Bool = false
    @State private var speechText: String = ""
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    let audioEngine = AVAudioEngine()
    @State private var isRecognizerPresented = false
    @StateObject private var imageRecognizer = ImageRecognizer()
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        return formatter
    }
    
    var body: some View {
        NavigationView {
            
            GeometryReader { proxy in
                VStack {
                    ScrollView {
                        if let image = self.image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .overlay(
                                    GeometryReader { imageProxy in
                                        ZStack {
                                            ForEach(annotations) { annotation in
                                                let boundingBox = annotation.boundingBox
                                                let annotationWidth = imageProxy.size.width * boundingBox.size.width
                                                let annotationHeight = imageProxy.size.height * boundingBox.size.height
                                                let annotationX = imageProxy.size.width * boundingBox.origin.x
                                                let annotationY = imageProxy.size.height * (1 - boundingBox.origin.y) - annotationHeight
                                                
                                                AnnotationView(annotation: annotation, proxy: proxy, onTapAction: {
                                                    print("Tapped Text: \(annotation.text)")
                                                    if let editingIndex = editingIndex {
                                                        if self.isEditingName {
                                                            self.receiptItems[editingIndex].name = annotation.text
                                                        }
                                                        if self.isEditingPrice {
                                                            if let number = Double(annotation.text) {
                                                                self.receiptItems[editingIndex].price = number
                                                            }
                                                        }
                                                        let totalPrice = receiptItems.reduce(0.0) { $0 + $1.price }
                                                        recepit.totalPrice = totalPrice
                                                    }
                                                })
                                                .frame(width: annotationWidth, height: annotationHeight)
                                                .position(x: annotationX + annotationWidth / 2, y: annotationY + annotationHeight / 2)
                                            }
                                        }
                                    }
                                )
                            
                            
                        }
                        Button("Scan Receipt") {
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
                        
                        VStack(spacing: 12) {
                            if !receiptItems.isEmpty {
                                Section(header:
                                            VStack {
                                    HStack {
                                        Text("Name")
                                        Button(action: {
                                            self.isRecording.toggle()
                                            if self.isRecording {
                                                self.startRecording()
                                            } else {
                                                self.stopRecording()
                                            }
                                        }) {
                                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                        }
                                        .padding()
                                        Text("Cost")
                                    }
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.gray)
                                        Text("Tap name field, then tap annotation to select current row input value.")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                                ) {
                                    ForEach(receiptItems.indices, id: \.self) { index in
                                        HStack {
                                            TextField("Name", text: Binding<String>(
                                                get: {
                                                    return self.receiptItems[index].name
                                                },
                                                set: { newValue in
                                                    self.receiptItems[index].name = newValue
                                                }
                                            ))
                                            .frame(maxWidth: .infinity)
                                            .onTapGesture {
                                                self.editingIndex = index
                                                self.isEditingName = true
                                                self.isEditingPrice = false
                                            }
                                            Button(action: {
                                                    self.editingIndex = index
                                                    self.isEditingName = true
                                                    self.isEditingPrice = false
                                                    openCameraForRecognize()
                                                }) {
                                                    Image(systemName: "camera.fill")
                                                        .foregroundColor(.blue)
                                            }
                                            HStack {
                                                Text("$")
                                                TextField("Cost", text: Binding<String>(
                                                    get: {
                                                        return String(format: "%.2f", self.receiptItems[index].price)
                                                    },
                                                    set: { newValue in
                                                        if let newValue = Double(newValue) {
                                                            self.receiptItems[index].price = newValue
                                                        }
                                                        
                                                    }
                                                ))
                                                .frame(maxWidth: 60)
                                                .onTapGesture {
                                                    self.editingIndex = index
                                                    self.isEditingName = false
                                                    self.isEditingPrice = true
                                                }
                                            }
                                        }
                                    }
                                    .onDelete(perform: { indexSet in
                                        receiptItems.remove(atOffsets: indexSet)
                                    })
                                    
                                }
                                
                                .padding()
                            } else {
                                Text("No items found.")
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                                .padding()
                        }
                    }
                    
                }
                
            }
            
            
        }
        .navigationBarTitle("Scan", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
//                    let newItem = RecepitItem(name: "", price: 0.0)
                    var item = RecepitItem()
                    item.date = recepit.date
//                    print(recepit.recepitId)
//                    print("232323")
                    item.recepitId = recepit.recepitId
                    
                    receiptItems.append(item)
                    
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    showingSubmitView = true
                    gptCate()
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            if let sourceType = self.sourceType {
                ImagePicker(image: self.$image, sourceType: sourceType)
                    .onChange(of: image) { newImage in
                        recognizeTextIfNeeded()
                    }
            }
        }
        .sheet(isPresented: $showingSubmitView){
                SummaryView(recepit: $recepit, receiptItems: $receiptItems, onSubmit: {
                    presentationMode.wrappedValue.dismiss()
            })

        }
        .sheet(isPresented: $isRecognizerPresented) {
            if let sourceType = self.sourceType {
                ImagePicker(image: self.$recognizeImage, sourceType: sourceType)
                    .onChange(of: recognizeImage) { newImage in
                        if let recognizeImage = newImage {
                            imageRecognizer.recognizePicture(recognizeImage)
                            if let editingIndex = editingIndex {
                                self.receiptItems[editingIndex].name = imageRecognizer.result
                            }
                        }
                    }
            }
        }
    }
    
    
    func openCamera() {
        sourceType = .camera
        isImagePickerPresented = true
    }
    
    func openPhotoLibrary() {
        sourceType = .photoLibrary
        isImagePickerPresented = true
    }
    func openCameraForRecognize() {
        sourceType = .camera
        isRecognizerPresented = true
    }
    
    private func recognizeTextIfNeeded() {
        if let image = image {
            recognizeText(image: image)
        }
    }
    
    func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Error recognizing text: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var recognizedText = ""
            recognizedTexts.removeAll()
            annotations.removeAll()
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
                recognizedTexts.append(topCandidate.string)
                annotations.append(Annotation(text: topCandidate.string, boundingBox: observation.boundingBox))
            }
            print(recognizedText)
            self.recognizedText = recognizedText
            
            self.recepit.recepitId = self.randomUUID.uuidString
            self.recepit.date = Date()
            self.recepit.recepitImage = image.resetImgSize(maxSizeKB: 100)
            
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing text recognition: \(error.localizedDescription)")
        }
    }
    


    func gptCate(){

            let name = receiptItems.map{$0.name}
            let namestr = name.joined(separator: ",")
            print(namestr)
            let questionstr = "Please categorize the following items separated by commas: \(namestr), according to following categories: \(categories.joined(separator: ", ")), just output the types in order separated by comma, without outputting any other information. For example: input(apple, book, banan) output(food, utilities, food)"

            print(questionstr)
            let gGe = OpenAI()
            gGe.ask(question: questionstr){ answer in
                if let answer = answer {
                    print("The answer is: \(answer)")
                    answerlist = answer.split(separator: ",").map(String.init)
                    if answerlist.count <= receiptItems.count  {
                        for (index, ans) in answerlist.enumerated() {
                        receiptItems[index].category = ans
                        print(receiptItems[index].category)
                        }
                    }
                    else {
                        print("gpt return too many answers")
                    }
                }

                }
            }
    
    private func startRecording() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
        }
        
        let recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { (result, _) in
            guard let result = result else { return }
            self.speechText = result.bestTranscription.formattedString
            if result.isFinal {
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        
        if let editingIndex = editingIndex {
            if  let number = Double(speechText),  self.isEditingPrice {
                self.receiptItems[editingIndex].price = number                
            } else {
                self.receiptItems[editingIndex].name = speechText
                
            }
            
        }
    }

}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}



