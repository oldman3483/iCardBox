//
//  OCRLearningView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/27.
//

import SwiftUI

struct OCRLearningView: View {
    @State private var wrongText = ""
    @State private var correctText = ""
    @State private var showingAlert = false
    @State private var customRules: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("新增OCR修正規則")) {
                    TextField("錯誤的文字", text: $wrongText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("正確的文字", text: $correctText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("新增規則") {
                        addCustomRule()
                    }
                    .disabled(wrongText.isEmpty || correctText.isEmpty)
                    .foregroundColor(.appPrimary)
                }
                
                Section(header: Text("現有的自定義規則")) {
                    if customRules.isEmpty {
                        Text("尚未新增自定義規則")
                            .foregroundColor(.textSecondary)
                    } else {
                        ForEach(Array(customRules.keys), id: \.self) { wrong in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("錯誤: \(wrong)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                    Text("正確: \(customRules[wrong] ?? "")")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                Spacer()
                                Button("刪除") {
                                    deleteRule(wrong)
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            }
                        }
                    }
                }
                
                Section(header: Text("內建修正規則")) {
                    ForEach(OCRCorrectionConfig.commonOCRErrors.indices, id: \.self) { index in
                        let rule = OCRCorrectionConfig.commonOCRErrors[index]
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("錯誤: \(rule.wrong)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("正確: \(rule.correct)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Text("內建")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("OCR學習")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadCustomRules()
            }
            .alert("規則已新增", isPresented: $showingAlert) {
                Button("確定") {}
            } message: {
                Text("OCR修正規則已成功新增")
            }
        }
    }
    
    private func addCustomRule() {
        OCRCorrectionConfig.saveCustomRule(wrong: wrongText, correct: correctText)
        loadCustomRules()
        wrongText = ""
        correctText = ""
        showingAlert = true
    }
    
    private func deleteRule(_ wrong: String) {
        var rules = OCRCorrectionConfig.loadCustomRules()
        rules.removeValue(forKey: wrong)
        
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: "CustomOCRRules")
        }
        
        loadCustomRules()
    }
    
    private func loadCustomRules() {
        customRules = OCRCorrectionConfig.loadCustomRules()
    }
}
