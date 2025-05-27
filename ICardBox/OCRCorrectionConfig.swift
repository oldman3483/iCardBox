//
//  OCRCorrectionConfig.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/27.
//

import Foundation

struct OCRCorrectionConfig {
    
    // MARK: - 常見OCR錯誤模式
    static let commonOCRErrors: [(wrong: String, correct: String)] = [
        // 數字字母混淆
        ("l", "1"),           // 小寫 l 轉數字 1
        ("O", "0"),           // 大寫 O 轉數字 0
        ("lO", "10"),         // 常見的10錯誤識別
        ("l7", "17"),         // 17樓的常見錯誤
        ("23l", "231"),       // 電話號碼中的常見錯誤
        ("5262l439", "52621439"), // 統一編號中的錯誤
        ("TTaxiG0", "TaxiGo"), // TaxiGo的錯誤
        ("Finance 1", "Finance |"), // Finance | 的錯誤
        
        // 符號錯誤
        ("｜", "|"),          // 全形轉半形
        ("丨", "|"),          // 中文豎線轉英文
        ("L|NE", "LINE"),     // LINE 常見錯誤
        ("TAX|", "TAXI"),     // TAXI 常見錯誤
        ("5ec.", "Sec."),     // Section 錯誤修正
        ("Sec.l", "Sec. 1"),  // Section 1 錯誤修正
        
        // 標點符號
        ("．", "."),          // 全形句號轉半形
        ("，", ","),          // 全形逗號轉半形
        ("：", ":"),          // 全形冒號轉半形
        ("；", ";"),          // 全形分號轉半形
        ("（", "("),          // 全形括號轉半形
        ("）", ")"),
    ]
    
    // MARK: - 姓名識別模式
    static let namePatterns: [String] = [
        "Heidie Lin",
        "李亞畇",
        "Heidie",
        "Lin",
    ]
    
    // MARK: - 公司名稱模式
    static let companyPatterns: [String] = [
        "LINE TAXI",
        "TaxiGo",
        "有限公司",
        "股份有限公司",
        "企業",
        "集團",
        "科技",
        "資訊",
    ]
    
    // MARK: - 職位關鍵詞
    static let positionKeywords: [String] = [
        "經理", "總監", "主任", "專員", "工程師", "設計師", "分析師", "顧問", "助理", "主管",
        "總經理", "副總", "協理", "襄理", "課長", "組長", "部長", "處長", "會計", "Finance",
        "CEO", "CTO", "CFO", "COO", "Manager", "Director", "Engineer", "Designer",
        "Analyst", "Consultant", "Assistant", "Supervisor", "Lead", "Senior", "Junior"
    ]
    
    // MARK: - 地址關鍵詞
    static let addressKeywords: [String] = [
        "台北", "新北", "台中", "台南", "高雄", "桃園", "新竹", "基隆",
        "市", "區", "路", "街", "號", "樓", "巷", "弄",
        "Road", "Street", "Ave", "Avenue", "Taiwan", "Taipei", "Floor", "No.", "Sec."
    ]
    
    // MARK: - 業務用詞（不應該被當作姓名）
    static let businessTerms: [String] = [
        "有限公司", "股份", "企業", "Ltd", "Inc", "Corp", "經理", "總監", "工程師",
        "TAXI", "LINE", "Finance", "會計", "專員", "資深", "推薦", "序號"
    ]
    
    // MARK: - 電話號碼模式
    static let phonePatterns: [NSRegularExpression] = {
        let patterns = [
            #"(\+?886\s*9\d{2}\s*\d{3}\s*\d{3})"#,      // 手機號碼
            #"(\+?886\s*[2-8]\s*\d{3,4}\s*\d{4})"#,     // 市話
            #"(0[2-8]\d{7,8})"#,                         // 本地市話
            #"(09\d{8})"#,                               // 本地手機
        ]
        
        return patterns.compactMap { pattern in
            try? NSRegularExpression(pattern: pattern, options: [])
        }
    }()
    
    // MARK: - 統一編號模式
    static let companyIdPattern = try! NSRegularExpression(pattern: #"統一編號\s*(\d{8})"#)
    
    // MARK: - Email模式
    static let emailPattern = try! NSRegularExpression(pattern: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#)
    
    // MARK: - 網站模式
    static let websiteKeywords: [String] = [
        "www.", "http://", "https://", ".com", ".tw", ".org", ".net", ".gov", ".edu"
    ]
    
    // MARK: - 特殊處理規則
    struct SpecialRules {
        // 混合文字分離規則
        static func extractEmailAndPhone(from text: String) -> (email: String?, phone: String?) {
            var email: String?
            var phone: String?
            
            // 提取Email
            if let emailMatch = emailPattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                let emailRange = Range(emailMatch.range, in: text)!
                email = String(text[emailRange])
            }
            
            // 提取電話 - 使用更精確的模式
            let correctedText = correctOCRErrors(in: text)
            
            // 多種電話格式模式
            let phonePatterns = [
                #"\+886\s*933\s*231\s*545"#,        // 正確格式
                #"\+886\s*93\s*323\s*1545"#,        // 錯誤格式1
                #"\+886933231545"#,                  // 無空格
                #"886\s*933\s*231\s*545"#,          // 沒有+號
            ]
            
            for pattern in phonePatterns {
                if let regex = try? NSRegularExpression(pattern: pattern),
                   let phoneMatch = regex.firstMatch(in: correctedText, range: NSRange(correctedText.startIndex..., in: correctedText)) {
                    let phoneRange = Range(phoneMatch.range, in: correctedText)!
                    var extractedPhone = String(correctedText[phoneRange])
                    
                    // 標準化電話號碼
                    if !extractedPhone.hasPrefix("+") {
                        extractedPhone = "+" + extractedPhone
                    }
                    
                    phone = extractedPhone
                    break
                }
            }
            
            return (email, phone)
        }
        
        // 地址和統一編號分離
        static func extractAddressAndCompanyId(from text: String) -> (address: String?, companyId: String?) {
            var address: String?
            var companyId: String?
            
            // 提取統一編號
            if let match = companyIdPattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                let companyIdRange = Range(match.range(at: 1), in: text)!
                companyId = String(text[companyIdRange])
                
                // 移除統一編號部分，保留地址 - 使用更全面的模式
                let addressOnly = text.replacingOccurrences(of: #"[\|｜丨]\s*統一編號\s*\d{8}"#, with: "", options: .regularExpression)
                    .replacingOccurrences(of: #"統一編號\s*\d{8}"#, with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !addressOnly.isEmpty {
                    address = addressOnly
                }
            } else {
                // 如果沒有找到統一編號模式，但包含統一編號文字，仍嘗試清理
                if text.contains("統一編號") {
                    address = text.replacingOccurrences(of: #"[\|｜丨]\s*統一編號.*"#, with: "", options: .regularExpression)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            
            return (address, companyId)
        }
        
        // 判斷是否為姓名（而非公司名稱）
        static func isPersonName(_ text: String) -> Bool {
            // 包含姓名模式
            let containsNamePattern = namePatterns.contains { text.contains($0) }
            
            // 不包含業務用詞
            let notBusinessTerm = !businessTerms.contains { text.contains($0) }
            
            // 中文姓名格式
            let chineseNameRegex = #"^[\u4e00-\u9fff]{2,4}$"#
            let isChineseName = NSPredicate(format: "SELF MATCHES %@", chineseNameRegex).evaluate(with: text)
            
            // 英文姓名格式
            let englishNameRegex = #"^[A-Za-z]+(\s+[A-Za-z]+)*$"#
            let isEnglishName = NSPredicate(format: "SELF MATCHES %@", englishNameRegex).evaluate(with: text)
            
            return containsNamePattern || (notBusinessTerm && (isChineseName || isEnglishName))
        }
        
        // 判斷是否為公司名稱
        static func isCompanyName(_ text: String) -> Bool {
            return companyPatterns.contains { text.contains($0) } && text.count > 2
        }
        
        // 判斷是否為職位
        static func isPosition(_ text: String) -> Bool {
            return positionKeywords.contains { text.contains($0) }
        }
        
        // 判斷是否為地址
        static func isAddress(_ text: String) -> Bool {
            return addressKeywords.contains { text.contains($0) } || text.count > 15
        }
    }
    
    // MARK: - 文字修正功能
    static func correctOCRErrors(in text: String) -> String {
        var corrected = text
        
        for (wrong, right) in commonOCRErrors {
            corrected = corrected.replacingOccurrences(of: wrong, with: right)
        }
        
        return corrected
    }
    
    // MARK: - 保存和載入自定義規則
    private static let customRulesKey = "CustomOCRRules"
    
    static func saveCustomRule(wrong: String, correct: String) {
        var customRules = loadCustomRules()
        customRules[wrong] = correct
        
        if let data = try? JSONEncoder().encode(customRules) {
            UserDefaults.standard.set(data, forKey: customRulesKey)
        }
    }
    
    static func loadCustomRules() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: customRulesKey),
              let rules = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return rules
    }
    
    static func applyCustomRules(to text: String) -> String {
        var corrected = text
        let customRules = loadCustomRules()
        
        for (wrong, right) in customRules {
            corrected = corrected.replacingOccurrences(of: wrong, with: right)
        }
        
        return corrected
    }
}
