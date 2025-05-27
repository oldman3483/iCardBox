//
//  BusinessCardManager.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import Foundation
import SwiftUI

class BusinessCardManager: ObservableObject {
    @Published var cards: [BusinessCard] = []
    
    func addCard(_ card: BusinessCard) {
        cards.append(card)
        saveCards()
    }
    
    func deleteCard(_ card: BusinessCard) {
        cards.removeAll { $0.id == card.id }
        saveCards()
    }
    
    func updateCard(_ card: BusinessCard) {
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
            saveCards()
        }
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(cards) {
            UserDefaults.standard.set(encoded, forKey: "SavedBusinessCards")
        }
    }
    
    private func loadCards() {
        if let data = UserDefaults.standard.data(forKey: "SavedBusinessCards"),
           let decoded = try? JSONDecoder().decode([BusinessCard].self, from: data) {
            cards = decoded
        }
    }
    
    init() {
        loadCards()
        if cards.isEmpty {
            let sampleCard = BusinessCard(
                name: "李亞昀",
                company: "LINE TAXI",
                position: "資深會計專員",
                phone: "+886 933 231 545",
                email: "heidie@taxigo.com.tw",
                website: "www.linetaxi.com.tw",
                address: "106台北市大安區安和路一段27號17樓",
                workPhone: "+886 2 2345 6789",
                englishAddress: "17F, No. 27, Sec.1, Anhe Rd., Da'an Dist., Taipei City 106, Taiwan",
                companyId: "52621439"
            )
            cards.append(sampleCard)
        }
    }
}
