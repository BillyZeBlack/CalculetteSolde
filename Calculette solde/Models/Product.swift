//
//  Product.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct Product: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var originalPrice: Decimal
    var discountRate: DiscountRate?
    var category: Category?
    var purchaseDate: Date?
    var note: String?

    var discountAmount: Decimal {
        guard let discountRate else { return 0 }
        return originalPrice * Decimal(discountRate.percentage) / 100
    }

    var finalPrice: Decimal {
        originalPrice - discountAmount
    }

    var hasDiscount: Bool {
        discountRate?.percentage ?? 0 > 0
    }

    init(
        id: UUID = UUID(),
        name: String,
        originalPrice: Decimal,
        discountRate: DiscountRate? = nil,
        category: Category? = nil,
        purchaseDate: Date? = nil,
        note: String? = nil
    ) {
        precondition(originalPrice >= 0, "Original price must be greater than or equal to 0.")
        self.id = id
        self.name = name
        self.originalPrice = originalPrice
        self.discountRate = discountRate
        self.category = category
        self.purchaseDate = purchaseDate
        self.note = note
    }
}
