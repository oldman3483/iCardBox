//
//  CommonComponents.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

// 搜尋欄 (模仿原設計)
struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 12)
            
            TextField("搜尋聯絡人...", text: $text)
                .padding(.vertical, 12)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 12)
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

// 名片列表項目 (完全模仿原設計)
struct BusinessCardRowView: View {
    let card: BusinessCard
    
    var body: some View {
        HStack(spacing: 12) {
            // 名片縮圖
            CardThumbnailView(imageData: card.imageData)
            
            // 名片資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(card.company)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // 右側箭頭
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.lightBackground)
    }
}

// 名片縮圖
struct CardThumbnailView: View {
    let imageData: Data?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .frame(width: 60, height: 38)
            
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 38)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Image(systemName: "person.crop.rectangle")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
            }
        }
    }
}

// 通用的名片圖片顯示 (用於詳細頁面)
struct CardImageView: View {
    let imageData: Data?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .cornerRadius(12)
        } else {
            Rectangle()
                .fill(Color.cardBackground)
                .frame(width: width, height: height)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: "creditcard")
                        .foregroundColor(.gray)
                        .font(.system(size: min(width, height) * 0.3))
                )
        }
    }
}

// 空狀態視圖 (完全模仿原設計)
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // 掃描框圖示
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 200, height: 130)
                
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
                .frame(width: 200, height: 130)
                
                Image(systemName: "creditcard")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text("掃描你的第一張名片")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text("開始建立你的名片收藏")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lightBackground)
    }
}

// 掃描框角落裝飾
struct CornerBracket: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    let position: Position
    
    var body: some View {
        Group {
            switch position {
            case .topLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().frame(width: 20, height: 3)
                    Rectangle().frame(width: 3, height: 20)
                }
            case .topRight:
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle().frame(width: 20, height: 3)
                    Rectangle().frame(width: 3, height: 20)
                }
            case .bottomLeft:
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().frame(width: 3, height: 20)
                    Rectangle().frame(width: 20, height: 3)
                }
            case .bottomRight:
                VStack(alignment: .trailing, spacing: 0) {
                    Rectangle().frame(width: 3, height: 20)
                    Rectangle().frame(width: 20, height: 3)
                }
            }
        }
        .foregroundColor(.appPrimary)
    }
}

// 方向切換按鈕
struct OrientationToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    let position: Position
    
    enum Position {
        case left, right
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.appPrimary : Color.cardBackground)
        }
        .clipShape(
            RoundedCorners(
                topLeft: position == .left ? 8 : 0,
                topRight: position == .right ? 8 : 0,
                bottomLeft: position == .left ? 8 : 0,
                bottomRight: position == .right ? 8 : 0
            )
        )
    }
}

// 圓角自定義形狀
struct RoundedCorners: Shape {
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: width, y: topRight))
        path.addArc(center: CGPoint(x: width - topRight, y: topRight), radius: topRight, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bottomLeft, y: height))
        path.addArc(center: CGPoint(x: bottomLeft, y: height - bottomLeft), radius: bottomLeft, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: bottomRight))
        path.addArc(center: CGPoint(x: bottomRight, y: bottomRight), radius: bottomRight, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.addLine(to: CGPoint(x: width - topLeft, y: 0))
        path.addArc(center: CGPoint(x: width - topLeft, y: topLeft), radius: topLeft, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 0), clockwise: false)
        
        return path
    }
}

// 設定項目行
struct SettingsRowView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var detail: String? = nil
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
