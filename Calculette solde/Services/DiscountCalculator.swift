//
//  DiscountCalculator.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct DiscountCalculationResult: Equatable, Hashable {
    let originalPrice: Decimal
    let discountRate: DiscountRate
    let discountAmount: Decimal
    let finalPrice: Decimal
}

struct DiscountCalculator {
    func calculate(originalPrice: Decimal, discountRate: DiscountRate) -> DiscountCalculationResult {
        let product = Product(
            name: "",
            originalPrice: originalPrice,
            discountRate: discountRate
        )

        return DiscountCalculationResult(
            originalPrice: originalPrice,
            discountRate: discountRate,
            discountAmount: product.discountAmount,
            finalPrice: product.finalPrice
        )
    }
}
