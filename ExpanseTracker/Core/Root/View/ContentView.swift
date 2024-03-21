//
//  ContentView.swift
//  ExpanseTracker
//
//  Created by Gytis Ptasinskas on 05/03/2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstTime") private var isFirstTime: Bool = true
    // App Lock Properties
    @AppStorage("isAppLockEnabled") private var isAppLockEnabled: Bool = false
    @AppStorage("lockWhenAppGoesBackground") private var lockWhenAppGoesBackground: Bool = false
    @AppStorage("userPin") private var userPin: String = ""
    // Active Tab
    @State private var activeTab: Tab = .recents
    
    var body: some View {
        LockView(lockType: .both, lockPin: userPin, isEnabled: isAppLockEnabled, lockWhenAppGoesBackground: lockWhenAppGoesBackground) {
                TabView(selection: $activeTab) {
                        RecentsView()
                            .tag(Tab.recents)
                            .tabItem { Tab.recents.tabContent }

                        SearchView()
                            .tag(Tab.search)
                            .tabItem { Tab.search.tabContent }
                        
                        GraphsView()
                            .tag(Tab.charts)
                            .tabItem { Tab.charts.tabContent }
                        
                        SettingsView()
                            .tag(Tab.settings)
                            .tabItem { Tab.settings.tabContent }

                }
                .fullScreenCover(isPresented: $isFirstTime) {
                    IntroView()
                        .interactiveDismissDisabled()
                }
        }
    }
}

#Preview {
    ContentView()
}
