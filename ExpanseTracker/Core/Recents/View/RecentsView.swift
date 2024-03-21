//
//  HomeView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI
import SwiftData
import RiveRuntime
struct RecentsView: View {
    // User Properties
    @AppStorage("userName") private var userName: String = ""
    
    // View Properties
    @State private var selectedCategory: Category = .expense
    @State private var startDate: Date = .now.startofMonth
    @State private var endDate: Date = .now.endfMonth
    @State private var showFilterView: Bool = false
    // Animation
    @Namespace private var animation
    var body: some View {
        GeometryReader {
            let size = $0.size
            NavigationStack {
                    ScrollView {
                        LazyVStack(spacing: 10, pinnedViews: [.sectionHeaders]) {
                            Section {
                                Button {
                                    showFilterView = true
                                } label: {
                                    HStack {
                                        Text("\(format(date: startDate, format: "dd - MMM yy")) to \(format(date: endDate, format: "dd - MMM yy"))")
                                          
                                        Image(systemName: "chevron.down")
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.black)
                                }
                                .hSpacing(.leading)
                                
                                FilterTransactionView(startDate: startDate, endDate: endDate) { transactions in
                                    // Card View
                                    CardView(
                                        income: total(transactions, category: .income),
                                        expense: total(transactions, category: .expense)
                                    )
                                    // Segmented Control
                                    CustomSegmentedControl()
                                        .padding(.bottom, 10)
                                    
                                    ForEach(transactions.filter({ $0.category == selectedCategory.rawValue })) { transaction in
                                        NavigationLink(value: transaction) {
                                            TransactionCardView(transaction: transaction)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            } header: {
                                HeaderView(size)
                            }
                        }
                        .padding(15)
                    }
                    .background(.gray.opacity(0.15))
                    .blur(radius: showFilterView ? 8 : 0)
                    .disabled(showFilterView)
                    .navigationDestination(for: Transaction.self) { transaction in
                        TransactionView(editTransaction: transaction)
                    }
            }
            .overlay {
                if showFilterView {
                    DateFilterView(start: startDate, end: endDate) { start, end in
                        startDate = start
                        endDate = end
                        showFilterView = false
                    } onClose: {
                        showFilterView = false
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .animation(.snappy, value: showFilterView)
        }
    }
    
    // Header View
    @ViewBuilder
    func HeaderView(_ size: CGSize) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Welcome!")
                    .font(.title).bold()
                
                if !userName.isEmpty {
                    Text(userName)
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
            .visualEffect { content, geometryProxy in
                content
                    .scaleEffect(headerScale(size, proxy: geometryProxy), anchor: .topLeading)
            }
            
            Spacer()
            
            NavigationLink {
                TransactionView()
            } label: {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(appTint.gradient, in: .circle)
                    .contentShape(.circle)
            }
        }
        .padding(.bottom, userName.isEmpty ? 10 : 5)
        .background {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                Divider()
            }
            .visualEffect { content, geometryProxy in
                content
                    .opacity(headerBGOpacity(geometryProxy))
            }
            .padding(.horizontal, -15)
            .padding(.top, -(safeArea.top + 15))
        }
    }
    
    // Segmented Control
    @ViewBuilder
    func CustomSegmentedControl() -> some View {
        HStack(spacing: 0) {
            ForEach(Category.allCases, id: \.rawValue) { category in
                Text(category.rawValue)
                    .hSpacing()
                    .padding(.vertical, 10)
                    .background {
                        if category == selectedCategory {
                            Capsule()
                                .fill(.background)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .contentShape(.capsule)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selectedCategory = category
                        }
                    }
            }
        }
        .background(.gray.opacity(0.15), in: .capsule)
        .padding(.top, 5)
    }
    
    func headerBGOpacity(_ proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY + safeArea.top
        return minY > 0 ? 0 : (-minY / 15)
    }
    
    func headerScale(_ size: CGSize, proxy: GeometryProxy) -> CGFloat {
        let minY = proxy.frame(in: .scrollView).minY
        let screenHeight = size.height
        
        let progress = minY / screenHeight
        let scale = min(max(progress, 0), 1) * 0.5
        
        return 1 + scale
    }
}

#Preview {
    ContentView()
}
