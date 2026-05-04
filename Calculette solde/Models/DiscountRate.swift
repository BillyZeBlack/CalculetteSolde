//
//  DiscountRate.swift
//  Calculette solde
//
//  Created by williams saadi on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//


struct DiscountRate: Identifiable, Equatable, Hashable {
    let percentage: Int

    var id: Int { percentage }
    var label: String { "\(percentage)%" }
    var fraction: Double { Double(percentage) / 100 }
    var remainingMultiplier: Double { 1 - fraction }

    init(percentage: Int) {
        precondition((0...100).contains(percentage), "Discount percentage must be between 0 and 100.")
        self.percentage = percentage
    }
}

extension DiscountRate {
    static let standardRates: [DiscountRate] = stride(from: 0, through: 90, by: 5)
        .map { DiscountRate(percentage: $0) }
}
