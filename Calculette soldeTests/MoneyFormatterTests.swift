//
//  MoneyFormatterTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

final class MoneyFormatterTests: XCTestCase {
    func testParsesFrenchDecimalFormat() {
        let formatter = MoneyFormatter(locale: Locale(identifier: "fr_FR"))

        XCTAssertEqual(formatter.parseDecimal("12,50"), Decimal(string: "12.50"))
        XCTAssertEqual(formatter.parseDecimal("1 234,56"), Decimal(string: "1234.56"))
    }

    func testParsesUSDecimalFormat() {
        let formatter = MoneyFormatter(locale: Locale(identifier: "en_US"))

        XCTAssertEqual(formatter.parseDecimal("12.50"), Decimal(string: "12.50"))
        XCTAssertEqual(formatter.parseDecimal("1,234.56"), Decimal(string: "1234.56"))
    }

    func testParsesGermanDecimalFormat() {
        let formatter = MoneyFormatter(locale: Locale(identifier: "de_DE"))

        XCTAssertEqual(formatter.parseDecimal("12,50"), Decimal(string: "12.50"))
        XCTAssertEqual(formatter.parseDecimal("1.234,56"), Decimal(string: "1234.56"))
    }

    func testRejectsInvalidDecimalInput() {
        let formatter = MoneyFormatter(locale: Locale(identifier: "fr_FR"))

        XCTAssertNil(formatter.parseDecimal(""))
        XCTAssertNil(formatter.parseDecimal("abc"))
        XCTAssertNil(formatter.parseDecimal("."))
        XCTAssertNil(formatter.parseDecimal(","))
    }

    func testDetectsWholeNumbers() {
        let formatter = MoneyFormatter(locale: Locale(identifier: "fr_FR"))

        XCTAssertEqual(formatter.wholeNumber(from: Decimal(25)), 25)
        XCTAssertNil(formatter.wholeNumber(from: Decimal(string: "25.5")!))
    }
}
