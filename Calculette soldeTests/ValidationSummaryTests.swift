//
//  ValidationSummaryTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

@MainActor
final class ValidationSummaryTests: XCTestCase {
    func testPrintsCurrentBusinessValidationSummary() {
        let formatterFR = MoneyFormatter(locale: Locale(identifier: "fr_FR"))
        let formatterUS = MoneyFormatter(locale: Locale(identifier: "en_US"))
        let formatterDE = MoneyFormatter(locale: Locale(identifier: "de_DE"))
        let calculator = DiscountCalculator()

        let frenchAmount = formatterFR.parseDecimal("1 234,56")
        let usAmount = formatterUS.parseDecimal("1,234.56")
        let germanAmount = formatterDE.parseDecimal("1.234,56")
        let calculation = calculator.calculate(
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 30)
        )

        let settingsStore = SettingsStore(settings: AppSettings(maximumBudget: Decimal(50)))
        let productStore = ProductStore()
        let mainViewModel = MainCalculatorViewModel(
            moneyFormatter: formatterFR,
            productStore: productStore,
            settingsStore: settingsStore
        )
        mainViewModel.productName = "Pull"
        mainViewModel.originalPriceText = "80"
        mainViewModel.selectDiscountRate(DiscountRate(percentage: 25))
        mainViewModel.calculate()
        mainViewModel.saveCurrentProduct()

        let recapViewModel = ProductRecapViewModel(
            productStore: productStore,
            moneyFormatter: formatterFR
        )

        XCTAssertEqual(frenchAmount, Decimal(string: "1234.56"))
        XCTAssertEqual(usAmount, Decimal(string: "1234.56"))
        XCTAssertEqual(germanAmount, Decimal(string: "1234.56"))
        XCTAssertEqual(calculation.discountAmount, Decimal(30))
        XCTAssertEqual(calculation.finalPrice, Decimal(70))
        XCTAssertEqual(mainViewModel.finalPrice, Decimal(60))
        XCTAssertTrue(mainViewModel.isOverBudget)
        XCTAssertEqual(productStore.products.count, 1)
        XCTAssertEqual(recapViewModel.totalOriginalPrice, Decimal(80))
        XCTAssertEqual(recapViewModel.totalDiscountAmount, Decimal(20))
        XCTAssertEqual(recapViewModel.totalFinalPrice, Decimal(60))

        let summary = """

            === Validation metier Calculette solde ===
            Locales:
            - fr_FR "1 234,56" -> \(frenchAmount?.description ?? "nil")
            - en_US "1,234.56" -> \(usAmount?.description ?? "nil")
            - de_DE "1.234,56" -> \(germanAmount?.description ?? "nil")

            Calcul remise:
            - Prix initial: \(calculation.originalPrice)
            - Remise: \(calculation.discountRate.percentage)%
            - Montant remise: \(calculation.discountAmount)
            - Prix final: \(calculation.finalPrice)

            ViewModel principal:
            - Prix final calcule: \(mainViewModel.finalPrice?.description ?? "nil")
            - Budget max: \(settingsStore.settings.maximumBudget?.description ?? "nil")
            - Budget depasse: \(mainViewModel.isOverBudget)
            - Produit sauvegarde: \(productStore.products.count)

            Recap:
            - Total initial: \(recapViewModel.totalOriginalPrice)
            - Total remises: \(recapViewModel.totalDiscountAmount)
            - Total final: \(recapViewModel.totalFinalPrice)
            =========================================

            """

        FileHandle.standardError.write(Data(summary.utf8))
        writeSummary(summary)
    }

    private func writeSummary(_ summary: String) {
        let reportURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("CalculetteSoldeValidationSummary.txt")

        try? summary.write(to: reportURL, atomically: true, encoding: .utf8)
    }
}
