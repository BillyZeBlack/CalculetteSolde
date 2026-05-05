//
//  MainCalculatorViewModelTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

@MainActor
final class MainCalculatorViewModelTests: XCTestCase {
    func testCalculatesWithSelectedDiscountRate() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = "100"
        viewModel.selectDiscountRate(DiscountRate(percentage: 30))
        viewModel.calculate()

        XCTAssertEqual(viewModel.originalPrice, Decimal(100))
        XCTAssertEqual(viewModel.discountAmount, Decimal(30))
        XCTAssertEqual(viewModel.finalPrice, Decimal(70))
        XCTAssertEqual(viewModel.selectedDiscountRate, DiscountRate(percentage: 30))
        XCTAssertNil(viewModel.errorMessage)
    }

    func testCalculatesWithCustomDiscountRate() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = "80"
        viewModel.customDiscountText = "15"
        viewModel.calculate()

        XCTAssertEqual(viewModel.discountAmount, Decimal(12))
        XCTAssertEqual(viewModel.finalPrice, Decimal(68))
        XCTAssertEqual(viewModel.selectedDiscountRate, DiscountRate(percentage: 15))
    }

    func testClearingSelectedDiscountRateKeepsCustomDiscountText() {
        let viewModel = makeViewModel()

        viewModel.selectDiscountRate(DiscountRate(percentage: 30))
        viewModel.customDiscountText = "15"
        viewModel.clearSelectedDiscountRate()

        XCTAssertNil(viewModel.selectedDiscountRate)
        XCTAssertEqual(viewModel.customDiscountText, "15")
    }

    func testRejectsInvalidOriginalPrice() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = "abc"
        viewModel.selectDiscountRate(DiscountRate(percentage: 10))
        viewModel.calculate()

        XCTAssertNil(viewModel.finalPrice)
        XCTAssertEqual(viewModel.errorMessage, "Le prix initial est invalide.")
    }

    func testRejectsSeparatorOnlyOriginalPrice() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = ","
        viewModel.selectDiscountRate(DiscountRate(percentage: 10))
        viewModel.calculate()

        XCTAssertNil(viewModel.finalPrice)
        XCTAssertEqual(viewModel.errorMessage, "Le prix initial est invalide.")
    }

    func testClearsErrorWhenOriginalPriceBecomesEmpty() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = ","
        viewModel.selectDiscountRate(DiscountRate(percentage: 10))
        viewModel.calculate()
        viewModel.originalPriceText = ""
        viewModel.calculate()

        XCTAssertNil(viewModel.originalPrice)
        XCTAssertNil(viewModel.finalPrice)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRejectsDecimalCustomDiscountRate() {
        let viewModel = makeViewModel()

        viewModel.originalPriceText = "100"
        viewModel.customDiscountText = "12,5"
        viewModel.calculate()

        XCTAssertNil(viewModel.finalPrice)
        XCTAssertEqual(viewModel.errorMessage, "La remise personnalisee doit etre un nombre entier.")
    }

    func testComparesFinalPriceAgainstBudget() {
        let settingsStore = SettingsStore(settings: AppSettings(maximumBudget: Decimal(50)))
        let viewModel = makeViewModel(settingsStore: settingsStore)

        viewModel.originalPriceText = "80"
        viewModel.selectDiscountRate(DiscountRate(percentage: 25))
        viewModel.calculate()

        XCTAssertEqual(viewModel.finalPrice, Decimal(60))
        XCTAssertTrue(viewModel.isOverBudget)
        XCTAssertEqual(viewModel.errorMessage, "Le prix final depasse le budget maximum.")
    }

    func testUpdatesBudgetStateWhenSettingsChange() {
        let settingsStore = SettingsStore(settings: AppSettings(maximumBudget: Decimal(50)))
        let viewModel = makeViewModel(settingsStore: settingsStore)

        viewModel.originalPriceText = "80"
        viewModel.selectDiscountRate(DiscountRate(percentage: 25))
        viewModel.calculate()
        settingsStore.settings = AppSettings(maximumBudget: Decimal(70))

        XCTAssertFalse(viewModel.isOverBudget)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDisablingCategoriesClearsSelectedCategory() {
        let category = Calculette_solde.Category.defaults[0]
        let settingsStore = SettingsStore(settings: AppSettings(allowsCategorySelection: true))
        let viewModel = makeViewModel(settingsStore: settingsStore)

        viewModel.selectedCategory = category
        settingsStore.settings = AppSettings(allowsCategorySelection: false)

        XCTAssertFalse(viewModel.canSelectCategory)
        XCTAssertNil(viewModel.selectedCategory)
    }

    func testAppliesLookupResultAndMatchesCategory() {
        let viewModel = makeViewModel()
        let barcode = Barcode(value: "3017620422003", symbology: .ean13)
        let result = ProductLookupResult(
            barcode: barcode,
            source: .openFoodFacts,
            name: "Pate a tartiner",
            categoryName: "Courses"
        )

        viewModel.applyLookupResult(result)

        XCTAssertEqual(viewModel.scannedBarcode, barcode)
        XCTAssertEqual(viewModel.productLookupResult, result)
        XCTAssertEqual(viewModel.productName, "Pate a tartiner")
        XCTAssertEqual(viewModel.selectedCategory, Calculette_solde.Category.defaults.first { $0.id == "groceries" })
    }

    func testSavesCurrentProductIntoSharedStore() {
        let productStore = ProductStore()
        let viewModel = makeViewModel(productStore: productStore)

        viewModel.productName = "Pull"
        viewModel.originalPriceText = "100"
        viewModel.selectDiscountRate(DiscountRate(percentage: 40))
        viewModel.calculate()
        viewModel.saveCurrentProduct()

        XCTAssertEqual(productStore.products.count, 1)
        XCTAssertEqual(productStore.products.first?.name, "Pull")
        XCTAssertEqual(productStore.products.first?.finalPrice, Decimal(60))
    }

    private func makeViewModel(
        productStore: ProductStore? = nil,
        settingsStore: SettingsStore? = nil
    ) -> MainCalculatorViewModel {
        MainCalculatorViewModel(
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR")),
            productStore: productStore,
            settingsStore: settingsStore
        )
    }
}
