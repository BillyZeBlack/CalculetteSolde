//
//  Category.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let systemImageName: String
    let isPremium: Bool
    let isCustom: Bool

    init(
        id: String,
        name: String,
        systemImageName: String,
        isPremium: Bool = false,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.systemImageName = systemImageName
        self.isPremium = isPremium
        self.isCustom = isCustom
    }
}

extension Category {
    static let freeDefaults: [Category] = [
        Category(id: "home", name: "Maison", systemImageName: "house"),
        Category(id: "clothing", name: "Vêtement", systemImageName: "tshirt"),
        Category(id: "groceries", name: "Nourriture", systemImageName: "fork.knife")
    ]

    static let premiumDefaults: [Category] = [
        Category(id: "beauty", name: "Beauté", systemImageName: "sparkles", isPremium: true),
        Category(id: "health", name: "Santé", systemImageName: "cross.case", isPremium: true),
        Category(id: "sport", name: "Sport", systemImageName: "figure.run", isPremium: true),
        Category(id: "electronics", name: "Électronique", systemImageName: "desktopcomputer", isPremium: true),
        Category(id: "leisure", name: "Loisirs", systemImageName: "gamecontroller", isPremium: true),
        Category(id: "children", name: "Enfants", systemImageName: "figure.2.and.child.holdinghands", isPremium: true),
        Category(id: "pets", name: "Animalerie", systemImageName: "pawprint", isPremium: true),
        Category(id: "car", name: "Auto", systemImageName: "car", isPremium: true),
        Category(id: "travel", name: "Voyage", systemImageName: "airplane", isPremium: true),
        Category(id: "gifts", name: "Cadeaux", systemImageName: "gift", isPremium: true),
        Category(id: "office", name: "Bureau", systemImageName: "briefcase", isPremium: true),
        Category(id: "garden", name: "Jardin", systemImageName: "leaf", isPremium: true),
        Category(id: "culture", name: "Culture", systemImageName: "book", isPremium: true),
        Category(id: "other", name: "Autre", systemImageName: "questionmark.circle", isPremium: true)
    ]

    static let defaults: [Category] = freeDefaults + premiumDefaults
}
