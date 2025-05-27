//
//  BusinessCardListView.swift
//  BCBox
//
//  Created by Heidie Lee on 2025/5/26.
//

import SwiftUI

struct BusinessCardListView: View {
    @EnvironmentObject var cardManager: BusinessCardManager
    @State private var searchText = ""
    @State private var showingAddCard = false
    @State private var showingSortOptions = false
    @State private var selectedSortOption: SortOption = .byName
    
    enum SortOption: String, CaseIterable {
        case byName = "按拼音排序"
        case bySurname = "按姓氏排序"
        case byRecentlyAdded = "最近新增排序"
        case byCompany = "按公司名稱排序"
        
        var icon: String {
            switch self {
            case .byName:
                return "textformat.abc"
            case .bySurname:
                return "person.fill"
            case .byRecentlyAdded:
                return "clock.fill"
            case .byCompany:
                return "building.2.fill"
            }
        }
    }
    
    var filteredAndSortedCards: [BusinessCard] {
        let filtered = searchText.isEmpty ? cardManager.cards : cardManager.cards.filter { card in
            card.name.localizedCaseInsensitiveContains(searchText) ||
            card.company.localizedCaseInsensitiveContains(searchText)
        }
        
        return sortCards(filtered, by: selectedSortOption)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightBackground.ignoresSafeArea()
                
                if cardManager.cards.isEmpty {
                    EmptyStateView()
                } else {
                    VStack(spacing: 0) {
                        // 自定義搜尋欄
                        SearchBarView(text: $searchText)
                            .padding(.horizontal, 16)
                            .padding(.top, 10)
                        
                        // 顯示目前排序方式
                        HStack {
                            Text("排序方式：\(selectedSortOption.rawValue)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                        // 名片列表
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                if !filteredAndSortedCards.isEmpty {
                                    // 根據排序方式決定是否要分組顯示
                                    if selectedSortOption == .byName || selectedSortOption == .bySurname {
                                        let groupedCards = Dictionary(grouping: filteredAndSortedCards) { card in
                                            getGroupingKey(for: card, sortOption: selectedSortOption)
                                        }
                                        
                                        ForEach(groupedCards.keys.sorted(), id: \.self) { groupKey in
                                            Section {
                                                ForEach(groupedCards[groupKey] ?? []) { card in
                                                    NavigationLink(destination: BusinessCardDetailView(card: card)) {
                                                        BusinessCardRowView(card: card)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            } header: {
                                                HStack {
                                                    Text(groupKey)
                                                        .font(.headline)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.textPrimary)
                                                        .padding(.leading, 16)
                                                        .padding(.vertical, 8)
                                                    Spacer()
                                                }
                                                .background(Color.lightBackground)
                                            }
                                        }
                                    } else {
                                        // 不分組顯示（按時間或公司排序時）
                                        ForEach(filteredAndSortedCards) { card in
                                            NavigationLink(destination: BusinessCardDetailView(card: card)) {
                                                BusinessCardRowView(card: card)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("名片列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.appPrimary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSortOptions = true }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .foregroundColor(.appPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddBusinessCardView()
                .environmentObject(cardManager)
        }
        .actionSheet(isPresented: $showingSortOptions) {
            ActionSheet(
                title: Text("選擇排序方式"),
                message: Text("請選擇名片的排序方式"),
                buttons: SortOption.allCases.map { option in
                    .default(Text("\(Image(systemName: option.icon)) \(option.rawValue)")) {
                        selectedSortOption = option
                    }
                } + [.cancel(Text("取消"))]
            )
        }
    }
    
    // 排序功能
    private func sortCards(_ cards: [BusinessCard], by sortOption: SortOption) -> [BusinessCard] {
        switch sortOption {
        case .byName:
            return cards.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .bySurname:
            return cards.sorted { getSurname($0.name).localizedCompare(getSurname($1.name)) == .orderedAscending }
        case .byRecentlyAdded:
            return cards.sorted { $0.createdDate > $1.createdDate }
        case .byCompany:
            return cards.sorted { $0.company.localizedCompare($1.company) == .orderedAscending }
        }
    }
    
    // 取得姓氏（中文名字的第一個字）
    private func getSurname(_ fullName: String) -> String {
        return String(fullName.prefix(1))
    }
    
    // 取得分組的 key
    private func getGroupingKey(for card: BusinessCard, sortOption: SortOption) -> String {
        switch sortOption {
        case .byName:
            return String(card.name.prefix(1)).uppercased()
        case .bySurname:
            return getSurname(card.name)
        case .byRecentlyAdded, .byCompany:
            return "" // 這些排序方式不需要分組
        }
    }
}
