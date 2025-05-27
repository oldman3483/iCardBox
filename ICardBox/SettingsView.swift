//
//  SettingsView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                // 會員服務區段
                Section {
                    SettingsRowView(
                        icon: "crown.fill",
                        title: "會員狀態",
                        subtitle: "免費版",
                        detail: "剩餘掃描次數：50",
                        color: .appPrimary
                    )
                    
                    SettingsRowView(
                        icon: "arrow.clockwise",
                        title: "復原購買",
                        color: .gray
                    )
                } header: {
                    Text("會員服務")
                        .foregroundColor(.appPrimary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // Pro 版功能
                Section {
                    SettingsRowView(
                        icon: "doc.text.fill",
                        title: "匯出成 Excel 檔",
                        color: .appPrimary
                    )
                    
                    NavigationLink(destination: OCRLearningView()) {
                        SettingsRowView(
                            icon: "brain.head.profile",
                            title: "OCR 學習",
                            subtitle: "自定義文字識別修正規則",
                            color: .appPrimary
                        )
                    }
                } header: {
                    Text("Pro 版功能")
                        .foregroundColor(.appPrimary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // 支援
                Section {
                    SettingsRowView(
                        icon: "hand.thumbsup.fill",
                        title: "評分",
                        color: .gray
                    )
                    
                    SettingsRowView(
                        icon: "message.fill",
                        title: "聯絡我們",
                        color: .gray
                    )
                } header: {
                    Text("支援")
                        .foregroundColor(.appPrimary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                // 版本資訊
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("Ver. 1.0.04")
                                .foregroundColor(.textSecondary)
                                .font(.caption)
                            
                            HStack(spacing: 4) {
                                Text("Made in Taiwan")
                                    .foregroundColor(.textSecondary)
                                    .font(.caption)
                                Text("❤️")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.lightBackground)
        }
    }
}
