//
//  DiscountCalculatorTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

final class DiscountCalculatorTests: XCTestCase {
    func testCalculatesDiscountAndFinalPrice() {
        let calculator = DiscountCalculator()

        let result = calculator.calculate(
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 25)
        )

        XCTAssertEqual(result.originalPrice, Decimal(100))
        XCTAssertEqual(result.discountRate, DiscountRate(percentage: 25))
        XCTAssertEqual(result.discountAmount, Decimal(25))
        XCTAssertEqual(result.finalPrice, Decimal(75))
    }

    func testZeroDiscountKeepsOriginalPrice() {
        let calculator = DiscountCalculator()

        let result = calculator.calculate(
            originalPrice: Decimal(string: "49.99")!,
            discountRate: DiscountRate(percentage: 0)
        )

        XCTAssertEqual(result.discountAmount, Decimal(0))
        XCTAssertEqual(result.finalPrice, Decimal(string: "49.99"))
    }
}
