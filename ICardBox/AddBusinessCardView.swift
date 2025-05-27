//
//  AddBusinessCardView.swift
//  ICardBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

struct AddBusinessCardView: View {
    @EnvironmentObject var cardManager: BusinessCardManager
    @Environment(\.presentationMode) var presentationMode
    @State private var card = BusinessCard()
    @State private var selectedLanguage = 0
    @State private var lineAccount = ""
    @State private var wechatAccount = ""
    @State private var showingSuccessAlert = false
    
    private let languages = ["繁體中文", "English"]
    
    // 新增：支援預填資料的初始化
    init(prefilledCard: BusinessCard? = nil) {
        if let prefilledCard = prefilledCard {
            _card = State(initialValue: prefilledCard)
            _lineAccount = State(initialValue: prefilledCard.socialMedia["LINE"] ?? "")
            _wechatAccount = State(initialValue: prefilledCard.socialMedia["WeChat"] ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 顯示掃描的名片圖片
                if let imageData = card.imageData {
                    Section {
                        HStack {
                            Spacer()
                            Image(uiImage: UIImage(data: imageData)!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 200)
                                .cornerRadius(12)
                            Spacer()
                        }
                    } header: {
                        SectionHeader(icon: "camera.fill", title: "掃描的名片")
                    }
                }
                
                // 識別結果提示
                if card.imageData != nil {
                    Section {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.appPrimary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("自動識別結果")
                                    .font(.headline)
                                    .foregroundColor(.appPrimary)
                                Text("請檢查並修正識別的資訊，確保資料正確無誤")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // 基本資訊
                Section(header: SectionHeader(icon: "person.fill", title: "基本資訊")) {
                    Picker("語言", selection: $selectedLanguage) {
                        ForEach(0..<languages.count, id: \.self) { index in
                            Text(languages[index])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("姓名", text: $card.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("職位", text: $card.position)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("公司", text: $card.company)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 聯絡資訊
                Section(header: SectionHeader(icon: "phone.fill", title: "聯絡資訊")) {
                    TextField("電話號碼", text: $card.phone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("工作電話", text: $card.workPhone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("傳真電話", text: $card.faxPhone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("電子郵件", text: $card.email)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("次要電子郵件", text: $card.secondaryEmail)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("網站", text: $card.website)
                        .keyboardType(.URL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 公司資訊
                Section(header: SectionHeader(icon: "building.2.fill", title: "公司資訊")) {
                    TextField("地址", text: $card.address, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("英文地址", text: $card.englishAddress, axis: .vertical)
                        .lineLimit(2...4)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("統一編號", text: $card.companyId)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // 社群媒體
                Section(header: SectionHeader(icon: "globe", title: "社群媒體")) {
                    TextField("LINE 帳號", text: $lineAccount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: lineAccount) { value in
                            card.socialMedia["LINE"] = value
                        }
                    TextField("WeChat 帳號", text: $wechatAccount)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: wechatAccount) { value in
                            card.socialMedia["WeChat"] = value
                        }
                }
            }
            .navigationTitle("新增名片")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveCard()
                    }
                    .foregroundColor(.appPrimary)
                    .disabled(card.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .preferredColorScheme(.light)
        .alert("儲存成功", isPresented: $showingSuccessAlert) {
            Button("確定") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("名片已成功儲存到你的收藏中")
        }
    }
    
    private func saveCard() {
        // 確保社群媒體資料同步
        if !lineAccount.isEmpty {
            card.socialMedia["LINE"] = lineAccount
        }
        if !wechatAccount.isEmpty {
            card.socialMedia["WeChat"] = wechatAccount
        }
        
        // 更新建立時間
        card.createdDate = Date()
        
        cardManager.addCard(card)
        showingSuccessAlert = true
    }
}

// 區段標題
struct SectionHeader: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.appPrimary)
            Text(title)
                .foregroundColor(.appPrimary)
        }
    }
}
