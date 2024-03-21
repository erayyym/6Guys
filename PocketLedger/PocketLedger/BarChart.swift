//
//  BarChart.swift
//  PocketLedger
//
//  Created by 倪达辰 on 21/3/24.
//

import SwiftUI

struct BarChart: View {
    let categories: [String: Double]
    let maxValue: Double
    
    init(categories: [String: Double]) {
        self.categories = categories
        self.maxValue = categories.values.max() ?? 0
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .bottom, spacing: 16) { // Use HStack for horizontal layout
                ForEach(categories.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                    VStack {
                        VStack {
                            Text(String(format: "$%.2f", total))
                                .font(.caption)
                            Text(category)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                        
                        VStack {
                            Spacer()
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: CGFloat(total / maxValue) * 200)
                                .alignmentGuide(.bottom) { _ in
                                    CGFloat(total / maxValue) * 200
                                }
                        }
                       
                    }
                    
                }
            }
        }
    }
}
