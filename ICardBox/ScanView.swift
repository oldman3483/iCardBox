//
//  ScanView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI
import UIKit

struct ScanView: View {
    @EnvironmentObject var cardManager: BusinessCardManager
    @StateObject private var textRecognizer = TextRecognitionManager()
    @State private var showingCamera = false
    @State private var selectedOrientation: ScanOrientation = .landscape
    @State private var showingImagePicker = false
    @State private var isProcessing = false
    @State private var showingAddCard = false
    @State private var recognizedCard: BusinessCard?
    
    enum ScanOrientation {
        case landscape, portrait
    }
    
    var body: some View {
        ZStack {
            Color.lightBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // 掃描框視覺效果
                VStack(spacing: 30) {
                    // 模仿原圖的掃描框
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                            .frame(width: 280, height: 180)
                        
                        // 四個角落的框線
                        VStack {
                            HStack {
                                CornerBracket(position: .topLeft)
                                Spacer()
                                CornerBracket(position: .topRight)
                            }
                            Spacer()
                            HStack {
                                CornerBracket(position: .bottomLeft)
                                Spacer()
                                CornerBracket(position: .bottomRight)
                            }
                        }
                        .frame(width: 280, height: 180)
                        
                        // 中間的名片圖示或處理中指示器
                        if isProcessing {
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                                    .scaleEffect(1.5)
                                Text("正在識別中...")
                                    .font(.caption)
                                    .foregroundColor(.appPrimary)
                                    .padding(.top, 8)
                            }
                        } else {
                            Image(systemName: "creditcard")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(spacing: 8) {
                        Text(isProcessing ? "正在識別名片內容" : "掃描你的第一張名片")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.textPrimary)
                        
                        Text(isProcessing ? "請稍候，正在分析圖片中的文字..." : "開始建立你的名片收藏")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // 底部按鈕區域
                VStack(spacing: 20) {
                    // 方向選擇按鈕
                    HStack(spacing: 0) {
                        OrientationToggleButton(
                            title: "橫向",
                            isSelected: selectedOrientation == .landscape,
                            action: { selectedOrientation = .landscape },
                            position: .left
                        )
                        
                        OrientationToggleButton(
                            title: "縱向",
                            isSelected: selectedOrientation == .portrait,
                            action: { selectedOrientation = .portrait },
                            position: .right
                        )
                    }
                    .frame(width: 200)
                    .disabled(isProcessing)
                    
                    // 中央相機按鈕 (模仿原設計)
                    Button(action: { showingCamera = true }) {
                        ZStack {
                            Circle()
                                .fill(isProcessing ? Color.gray : Color.black)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                                .foregroundColor(isProcessing ? .gray : .black)
                        }
                    }
                    .disabled(isProcessing)
                    
                    // 底部額外按鈕 (從相簿選擇等)
                    HStack(spacing: 60) {
                        Button(action: { showingImagePicker = true }) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundColor(isProcessing ? .gray : .gray)
                        }
                        .disabled(isProcessing)
                        
                        Spacer().frame(width: 80) // 中間空間給相機按鈕
                        
                        Button(action: {}) {
                            Image(systemName: "flashlight.off.fill")
                                .font(.system(size: 24))
                                .foregroundColor(isProcessing ? .gray : .gray)
                        }
                        .disabled(isProcessing)
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                handleScannedImage(image)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                handleScannedImage(image)
            }
        }
        .sheet(isPresented: $showingAddCard) {
            if let card = recognizedCard {
                AddBusinessCardView(prefilledCard: card)
                    .environmentObject(cardManager)
            }
        }
    }
    
    private func handleScannedImage(_ image: UIImage) {
        isProcessing = true
        
        textRecognizer.recognizeText(from: image) { recognizedCard in
            self.recognizedCard = recognizedCard
            self.isProcessing = false
            self.showingAddCard = true
        }
    }
}
