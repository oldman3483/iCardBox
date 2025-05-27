//
//  Models.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import Foundation
import SwiftUI

struct BusinessCard: Identifiable, Codable {
    let id = UUID()
    
    // 姓名 - 支援中英文分離
    var name: String
    var englishName: String
    var chineseName: String
    
    var company: String
    
    // 職位 - 支援中英文分離
    var position: String
    var englishPosition: String
    var chinesePosition: String 
    
    var phone: String
    var email: String
    var website: String
    var address: String
    var workPhone: String
    var faxPhone: String
    var secondaryEmail: String
    var englishAddress: String
    var companyId: String
    var socialMedia: [String: String]
    var imageData: Data?
    var createdDate: Date
    
    init(name: String = "", englishName: String = "", chineseName: String = "",
         company: String = "", position: String = "", englishPosition: String = "", chinesePosition: String = "",
         phone: String = "", email: String = "", website: String = "",
         address: String = "", workPhone: String = "", faxPhone: String = "",
         secondaryEmail: String = "", englishAddress: String = "",
         companyId: String = "", socialMedia: [String: String] = [:],
         imageData: Data? = nil, createdDate: Date? = nil) {
        self.name = name
        self.englishName = englishName
        self.chineseName = chineseName
        self.company = company
        self.position = position
        self.englishPosition = englishPosition
        self.chinesePosition = chinesePosition
        self.phone = phone
        self.email = email
        self.website = website
        self.address = address
        self.workPhone = workPhone
        self.faxPhone = faxPhone
        self.secondaryEmail = secondaryEmail
        self.englishAddress = englishAddress
        self.companyId = companyId
        self.socialMedia = socialMedia
        self.imageData = imageData
        self.createdDate = createdDate ?? Date()
    }
    
    // 便利方法：自動分離中英文姓名
    mutating func setName(fullName: String) {
        self.name = fullName
        
        // 分離中英文姓名
        let parts = fullName.components(separatedBy: " ")
        var englishParts: [String] = []
        var chineseParts: [String] = []
        
        for part in parts {
            if part.range(of: #"[\u4e00-\u9fff]"#, options: .regularExpression) != nil {
                // 包含中文字符
                chineseParts.append(part)
            } else if !part.isEmpty {
                // 英文字符
                englishParts.append(part)
            }
        }
        
        self.englishName = englishParts.joined(separator: " ")
        self.chineseName = chineseParts.joined(separator: " ")
    }
    
    // 便利方法：自動分離中英文職位
    mutating func setPosition(fullPosition: String) {
        self.position = fullPosition
        
        // 分離中英文職位
        if fullPosition.contains("|") {
            let parts = fullPosition.components(separatedBy: "|")
            if parts.count >= 2 {
                self.englishPosition = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                self.chinesePosition = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            // 沒有分隔符，嘗試自動判斷
            if fullPosition.range(of: #"[\u4e00-\u9fff]"#, options: .regularExpression) != nil {
                // 包含中文，假設全部是中文職位
                self.chinesePosition = fullPosition
                self.englishPosition = ""
            } else {
                // 不包含中文，假設是英文職位
                self.englishPosition = fullPosition
                self.chinesePosition = ""
            }
        }
    }
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let icon: String
    let color: Color
    let isPro: Bool
    
    init(title: String, subtitle: String? = nil, icon: String, color: Color = .orange, isPro: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.isPro = isPro
    }
}

// 新增：文字識別錯誤類型
enum TextRecognitionError: Error, LocalizedError {
    case imageProcessingFailed
    case noTextFound
    case recognitionFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "圖片處理失敗"
        case .noTextFound:
            return "未在圖片中找到文字"
        case .recognitionFailed:
            return "文字識別失敗"
        }
    }
}
