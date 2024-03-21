//
//  AnnotationView.swift
//  PocketLedger
//
//  Created by Chen Yang on 3/21/24.
//

import SwiftUI

struct AnnotationView: View {
   var annotation: Annotation
   var proxy: GeometryProxy
    var onTapAction: () -> Void

   var body: some View {
       Text(annotation.text)
           .foregroundColor(.white)
           .padding(0)
           .background(Color.red.opacity(0.5))
           .font(.system(size: 12))
           .onTapGesture {
               onTapAction()
           }
   }
}
struct Annotation: Identifiable {
   let id = UUID()
   var text: String
   var boundingBox: CGRect
}
