//
//  MainView.swift
//  PocketLedger
//
//  Created by Yang Gao on 2024/3/17.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: ScanView()) {
                    Text("Scan")
                        .foregroundColor(.blue)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitle("PocketLedger", displayMode: .inline)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
