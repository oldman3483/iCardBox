//
//  ContentView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cardManager = BusinessCardManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BusinessCardListView()
                .environmentObject(cardManager)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "folder.fill" : "folder")
                    Text("名片列表")
                }
                .tag(0)
            
            ScanView()
                .environmentObject(cardManager)
                .tabItem {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 30))
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                    Text("設定")
                }
                .tag(2)
        }
        .accentColor(.appPrimary)
        .preferredColorScheme(.light) // 強制淺色模式
    }
}
