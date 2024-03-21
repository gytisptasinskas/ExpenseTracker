//
//  IntroView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI
import RiveRuntime

struct IntroView: View {
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    var body: some View {
        ZStack {
            RiveViewModel(fileName: "background").view()
                .ignoresSafeArea()
                .blur(radius: 20)
            VStack {
                Text("What's New in the\nExpense Tracker")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 65)
                    .padding(.bottom, 35)
                
                VStack(alignment: .leading, spacing: 25) {
                    PointView(symbol: "dollarsign", title: "Transactions", subtitle: "Keep tract of your earnings and expenses")
                    
                    PointView(symbol: "chart.bar.fill", title: "Visual Charts", subtitle: "View your transactions using eye-catching graphic representations.")
                    
                    PointView(symbol: "magnifyingglass", title: "Advance Filters", subtitle: "Find the expenses you want by advance search and filtering.")
                }
                .hSpacing(.leading)
                .padding(.horizontal, 15)
                
                Button("Continue") {
                    isFirstTime = false
                }
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(appTint.gradient, in: .rect(cornerRadius: 12))
                .padding()
                
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            

        }
    }
    
    @ViewBuilder
    func PointView(symbol: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 20) {
            Image(systemName: symbol)
                .font(.largeTitle)
                .foregroundStyle(appTint.gradient)
                .frame(width: 45)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    IntroView()
}
