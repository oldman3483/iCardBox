//
//  BusinessCardDetailView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

struct BusinessCardDetailView: View {
    let card: BusinessCard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 名片圖片
                if let imageData = card.imageData {
                    CardImageView(
                        imageData: imageData,
                        width: UIScreen.main.bounds.width - 40,
                        height: 200
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 20)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // 基本資訊卡片
                    PersonalInfoCard(card: card)
                    
                    // 聯絡方式卡片
                    if hasContactInfo(card) {
                        ContactInfoCard(card: card)
                    }
                    
                    // 公司資訊卡片
                    if hasCompanyInfo(card) {
                        CompanyInfoCard(card: card)
                    }
                    
                    // 社群媒體卡片
                    if !card.socialMedia.isEmpty {
                        SocialMediaCard(card: card)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.lightBackground)
        .preferredColorScheme(.light)
    }
    
    private func hasContactInfo(_ card: BusinessCard) -> Bool {
        !card.phone.isEmpty || !card.email.isEmpty || !card.website.isEmpty ||
        !card.workPhone.isEmpty || !card.faxPhone.isEmpty || !card.secondaryEmail.isEmpty
    }
    
    private func hasCompanyInfo(_ card: BusinessCard) -> Bool {
        !card.address.isEmpty || !card.englishAddress.isEmpty || !card.companyId.isEmpty
    }
}

// 詳細資訊卡片元件
struct PersonalInfoCard: View {
    let card: BusinessCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            if !card.position.isEmpty {
                Text(card.position)
                    .font(.headline)
                    .foregroundColor(.textSecondary)
            }
            
            if !card.company.isEmpty {
                Text(card.company)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct ContactInfoCard: View {
    let card: BusinessCard
    
    var body: some View {
        InfoCard(title: "聯絡方式", icon: "phone.fill") {
            ContactInfoRow(icon: "phone", text: card.phone, label: "電話")
            ContactInfoRow(icon: "phone.badge.plus", text: card.workPhone, label: "工作電話")
            ContactInfoRow(icon: "fax", text: card.faxPhone, label: "傳真")
            ContactInfoRow(icon: "envelope", text: card.email, label: "電子郵件")
            ContactInfoRow(icon: "envelope.badge", text: card.secondaryEmail, label: "次要電子郵件")
            ContactInfoRow(icon: "globe", text: card.website, label: "網站")
        }
    }
}

struct CompanyInfoCard: View {
    let card: BusinessCard
    
    var body: some View {
        InfoCard(title: "公司資訊", icon: "building.2.fill") {
            ContactInfoRow(icon: "location", text: card.address, label: "地址")
            ContactInfoRow(icon: "location.circle", text: card.englishAddress, label: "英文地址")
            ContactInfoRow(icon: "number", text: card.companyId, label: "統一編號")
        }
    }
}

struct SocialMediaCard: View {
    let card: BusinessCard
    
    var body: some View {
        InfoCard(title: "社群媒體", icon: "globe") {
            ForEach(Array(card.socialMedia.keys), id: \.self) { platform in
                if let account = card.socialMedia[platform], !account.isEmpty {
                    ContactInfoRow(icon: "message", text: account, label: platform)
                }
            }
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appPrimary)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.appPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct ContactInfoRow: View {
    let icon: String
    let text: String
    let label: String
    
    var body: some View {
        if !text.isEmpty {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appPrimary)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(text)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
            }
        }
    }
}
