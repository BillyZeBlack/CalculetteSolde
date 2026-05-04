//
//  Category.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let systemImageName: String

    init(id: String, name: String, systemImageName: String) {
        self.id = id
        self.name = name
        self.systemImageName = systemImageName
    }
}

extension Category {
    static let defaults: [Category] = [
        Category(id: "clothing", name: "Vetements", systemImageName: "tshirt"),
        Category(id: "shoes", name: "Chaussures", systemImageName: "shoeprints.fill"),
        Category(id: "home", name: "Maison", systemImageName: "house"),
        Category(id: "tech", name: "High-tech", systemImageName: "desktopcomputer"),
        Category(id: "groceries", name: "Courses", systemImageName: "cart"),
        Category(id: "leisure", name: "Loisirs", systemImageName: "gamecontroller"),
        Category(id: "other", name: "Autres", systemImageName: "questionmark.circle")
    ]
}
