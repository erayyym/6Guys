//
//  ScanView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//


import SwiftUI
import Vision
import Combine

struct ScanView: View {
    
    
    
    @State private var recepit: Recepit = Recepit()
    @State private var receiptItems: [RecepitItem] = []
    @State private var names: [String] = []
    @State var answerlist: [String] = []
    @State private var recognizedText = ""
    @State var image: UIImage?
    @State private var showingActionSheet = false
    @State private var showingSubmitView = false
    private let randomUUID = UUID()

    @State private var isImagePickerPresented = false
    @State private var sourceType: UIImagePickerController.SourceType?
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        return formatter
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                    }
                    
                    Button("Scan Receipt") {
                        showingActionSheet = true
                    }
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
                    
                    
                    if !receiptItems.isEmpty {
                        Section(header:
                                    HStack {
                            Text("Name")
                            Spacer()
                            Text("Cost")
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
                                    
                                    HStack {
                                        Text("$")
                                        TextField("Cost", value: $receiptItems[index].price, formatter: numberFormatter)
                                            .frame(maxWidth: 60)
                                    }
                                }
                            }
                        }
                        .padding()
                    } else {
                        Text("No items found.")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding()
            }

        }
        .navigationBarTitle("Scan", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    showingSubmitView = true
                    //这里加上生成cate的function，更新cate gptpart
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
//            NavigationView{ //这里要说写了 navigationview会出现两次 然后那个summary 和confirm会出现两次
            //being wrapped in another NavigationView when it's being used.
                SummaryView(recepit: $recepit, receiptItems: $receiptItems)
//            }
            
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
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                recognizedText += topCandidate.string + "\n"
            }
            print(recognizedText)
            self.recognizedText = recognizedText
            print(self.recognizedText)
            
            self.recepit.recepitId = self.randomUUID.uuidString
            self.recepit.date = Date()
            self.recepit.recepitImage = image.resetImgSize(maxSizeKB: 100)
            
            receiptItems = parseItemsFromReceipt(recognizedText)
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing text recognition: \(error.localizedDescription)")
        }
    }
    
    func parseItemsFromReceipt(_ text: String) -> [RecepitItem] {
        var items: [RecepitItem] = []
        
        var prices:[Double] = []
        var nameStartIndex = 0
        var nameEndIndex = 0
        var priceStartIndex = 0
        var totalPrice = 0.0
        let lines = text.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            if index > 0 {
                let lastLine = lines[index - 1]
                if lastLine == "E" && line != "E" {
                    nameStartIndex = index
                }
                
                if line.hasSuffix("SUBTOTAL") {
                    nameEndIndex = index
                }
                
                if nameEndIndex > nameStartIndex && names.isEmpty {
                    let subArray = lines[nameStartIndex..<nameEndIndex]
                    for (_, nameStr) in subArray.enumerated() {
                        var  arr = nameStr.components(separatedBy: " ")
                        var result = ""
                        if arr.count > 1 {
                            arr.removeFirst()
                            result = arr.joined(separator: " ")
                            names.append(result)
                        } else {
                            result = arr[0]
                            names.append(result)
                        }
                    }
                }
                
                if line.hasSuffix(" E") && !lastLine.hasSuffix(" E") {
                    priceStartIndex = index
                    let subArray = lines[priceStartIndex..<priceStartIndex + (names.count)]
                    for (_, priceStr) in subArray.enumerated() {
                        if priceStr.hasSuffix(" E") {
                            if let priceStr = priceStr.components(separatedBy: " ").first, let doubleValue = Double(priceStr) {
                                prices.append(doubleValue)
                            }
                        } else {
                            prices.append(Double(priceStr) ?? 0)
                        }
                    }
                }
            }
        }
        
        for (index, price) in prices.enumerated() {
            var item = RecepitItem()
            item.date = recepit.date
            item.recepitId = recepit.recepitId
            item.name = names[index]
            item.price = price
            items.append(item)
            totalPrice += price
        }
        self.recepit.totalPrice = totalPrice
        
        return items
    }
    
    func gptCate(){
            /*1. 所有name放出来
             2. name 加上问题发给gpt
             3. gpt的回答放到list里
             4. gpt的回答更新stuct cate的value
             */
            
            let name = receiptItems.map{$0.name}
            let namestr = name.joined(separator: ",")
            print(namestr)
            let questionstr = "Here are a list of object name (\(namestr)), please based on (\(categories.joined(separator: ","))) to categories those object.(different name are seprate by , ) please return me just the answer of the categories of those object and seprate them using , just like how I give those objectname and categoriest to you. finally only give me the list of cotegories in this form:Drink,Drink,Electronics"
            
            print(questionstr)
            let gGe = OpenAI()
            gGe.ask(question: questionstr){ answer in
                if let answer = answer {
                    print("The answer is: \(answer)")
                    answerlist = answer.split(separator: ",").map(String.init)
                    if receiptItems.count == answerlist.count {
                        for (index, ans) in answerlist.enumerated() {
                            receiptItems[index].category = ans
                            print(receiptItems[index].category)
                        }
                    } else {
                        print("The count of new values does not match the count of objects.")
                    }

                    } else {
                        print("There was an error or no answer available.")
                    }
            }

    //        if receiptItems.count == answerlist.count {
    //            for (index, ans) in answerlist.enumerated() {
    //                receiptItems[index].category = ans
    //                print(receiptItems[index].category)
    //            }
    //        } else {
    //            print("The count of new values does not match the count of objects.")
    //        }
    //
    //        ForEach($receiptItems, id: \.id) { $item in
    //
    //        }
        }
    
    
    
}



struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}



