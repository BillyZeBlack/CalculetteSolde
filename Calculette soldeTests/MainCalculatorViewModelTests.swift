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

    func testComparesSavedProductsTotalAgainstBudget() {
        let settingsStore = SettingsStore(settings: AppSettings(maximumBudget: Decimal(50)))
        let productStore = ProductStore()
        let viewModel = makeViewModel(productStore: productStore, settingsStore: settingsStore)

        productStore.add(Product(name: "Pull", originalPrice: Decimal(80), discountRate: DiscountRate(percentage: 25)))

        XCTAssertEqual(viewModel.savedProductsTotal, Decimal(60))
        XCTAssertTrue(viewModel.isOverBudget)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUpdatesBudgetStateWhenSettingsChange() {
        let settingsStore = SettingsStore(settings: AppSettings(maximumBudget: Decimal(50)))
        let productStore = ProductStore(products: [
            Product(name: "Pull", originalPrice: Decimal(80), discountRate: DiscountRate(percentage: 25))
        ])
        let viewModel = makeViewModel(productStore: productStore, settingsStore: settingsStore)

        XCTAssertTrue(viewModel.isOverBudget)

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
        XCTAssertEqual(viewModel.savedProducts.count, 1)
        XCTAssertEqual(viewModel.savedProducts.first?.name, "Pull")
        XCTAssertEqual(viewModel.formattedSavedProductsTotal, "60,00 €")
    }

    func testRejectsSavingProductWithZeroPrice() {
        let productStore = ProductStore()
        let viewModel = makeViewModel(productStore: productStore)

        viewModel.productName = "Produit gratuit"
        viewModel.originalPriceText = "0"
        viewModel.selectDiscountRate(DiscountRate(percentage: 0))

        XCTAssertFalse(viewModel.saveCurrentProduct())
        XCTAssertTrue(productStore.products.isEmpty)
        XCTAssertTrue(viewModel.savedProducts.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, "Renseignez un prix supérieur à 0 € pour ajouter ce produit.")
    }

    func testSavesDistinctProductsIntoSharedStore() {
        let productStore = ProductStore()
        let viewModel = makeViewModel(productStore: productStore)

        viewModel.productName = "Pull"
        viewModel.originalPriceText = "100"
        viewModel.selectDiscountRate(DiscountRate(percentage: 40))
        viewModel.calculate()
        viewModel.saveCurrentProduct()

        viewModel.productName = "Pantalon"
        viewModel.originalPriceText = "50"
        viewModel.selectDiscountRate(DiscountRate(percentage: 20))
        viewModel.calculate()
        viewModel.saveCurrentProduct()

        XCTAssertEqual(productStore.products.count, 2)
        XCTAssertEqual(productStore.products.map(\.name), ["Pull", "Pantalon"])
        XCTAssertNotEqual(productStore.products[0].id, productStore.products[1].id)
        XCTAssertEqual(viewModel.savedProducts.count, 2)
        XCTAssertEqual(viewModel.formattedSavedProductsTotal, "100,00 €")
    }

    func testRemovesSavedProductFromSharedStore() {
        let product = Product(
            name: "Pull",
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 40)
        )
        let productStore = ProductStore(products: [product])
        let viewModel = makeViewModel(productStore: productStore)

        viewModel.removeSavedProduct(product)

        XCTAssertTrue(productStore.products.isEmpty)
        XCTAssertTrue(viewModel.savedProducts.isEmpty)
        XCTAssertEqual(viewModel.formattedSavedProductsTotal, "0,00 €")
    }

    func testClearsSavedProductsFromSharedStore() {
        let products = [
            Product(
                name: "Pull",
                originalPrice: Decimal(100),
                discountRate: DiscountRate(percentage: 40)
            ),
            Product(
                name: "Pantalon",
                originalPrice: Decimal(50),
                discountRate: DiscountRate(percentage: 20)
            )
        ]
        let productStore = ProductStore(products: products)
        let viewModel = makeViewModel(productStore: productStore)

        viewModel.clearSavedProducts()

        XCTAssertTrue(productStore.products.isEmpty)
        XCTAssertTrue(viewModel.savedProducts.isEmpty)
        XCTAssertEqual(viewModel.formattedSavedProductsTotal, "0,00 €")
    }

    func testAssignsCategoryToSavedProduct() {
        let product = Product(
            name: "Pull",
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 40)
        )
        let productStore = ProductStore(products: [product])
        let viewModel = makeViewModel(productStore: productStore)
        let category = Calculette_solde.Category.defaults[0]

        viewModel.assignCategory(category, to: product)

        XCTAssertEqual(productStore.products.first?.category, category)
        XCTAssertEqual(viewModel.savedProducts.first?.category, category)
        XCTAssertEqual(productStore.products.first?.id, product.id)
    }

    func testPersistsCustomCategoriesInInjectedDefaultsStore() {
        let suiteName = "CategoryStoreTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let categoryStore = CategoryStore(userDefaults: userDefaults)
        let category = categoryStore.addCustomCategory(named: "Jeux")

        let reloadedCategoryStore = CategoryStore(userDefaults: userDefaults)

        XCTAssertNotNil(category)
        XCTAssertEqual(reloadedCategoryStore.customCategories, [category])
    }

    func testRemovesCustomCategoriesFromInjectedDefaultsStore() {
        let suiteName = "CategoryStoreTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        let categoryStore = CategoryStore(userDefaults: userDefaults)
        let category = categoryStore.addCustomCategory(named: "Jeux")!

        XCTAssertTrue(categoryStore.removeCustomCategory(category))

        let reloadedCategoryStore = CategoryStore(userDefaults: userDefaults)
        XCTAssertTrue(reloadedCategoryStore.customCategories.isEmpty)
    }

    func testLookupScannedProductFillsProductName() async {
        let barcode = Barcode(value: "3017620422003", symbology: .ean13)
        let result = ProductLookupResult(
            barcode: barcode,
            source: .openFoodFacts,
            name: "Pate a tartiner",
            categoryName: "Courses"
        )
        let viewModel = makeViewModel(
            productLookupService: ProductLookupServiceMock(result: result)
        )

        await viewModel.lookupScannedProduct(for: barcode)

        XCTAssertEqual(viewModel.scannedBarcode, barcode)
        XCTAssertEqual(viewModel.productLookupResult, result)
        XCTAssertEqual(viewModel.productName, "Pate a tartiner")
        XCTAssertEqual(viewModel.selectedCategory, Calculette_solde.Category.defaults.first { $0.id == "groceries" })
        XCTAssertFalse(viewModel.isLookingUpScannedProduct)
        XCTAssertNil(viewModel.productLookupErrorMessage)
    }

    func testLookupScannedProductHandlesMissingProduct() async {
        let barcode = Barcode(value: "3017620422003", symbology: .ean13)
        let viewModel = makeViewModel(
            productLookupService: ProductLookupServiceMock(result: nil)
        )

        await viewModel.lookupScannedProduct(for: barcode)

        XCTAssertNil(viewModel.productLookupResult)
        XCTAssertEqual(viewModel.productLookupErrorMessage, "Produit introuvable pour ce code-barres.")
        XCTAssertFalse(viewModel.isLookingUpScannedProduct)
    }

    func testLookupScannedProductHandlesError() async {
        let barcode = Barcode(value: "3017620422003", symbology: .ean13)
        let viewModel = makeViewModel(
            productLookupService: ProductLookupServiceMock(error: ProductLookupError.invalidResponse)
        )

        await viewModel.lookupScannedProduct(for: barcode)

        XCTAssertNil(viewModel.productLookupResult)
        XCTAssertEqual(viewModel.productLookupErrorMessage, "Impossible de récupérer les informations du produit.")
        XCTAssertFalse(viewModel.isLookingUpScannedProduct)
    }

    private func makeViewModel(
        productStore: ProductStore? = nil,
        settingsStore: SettingsStore? = nil,
        productLookupService: ProductLookupServicing = ProductLookupServiceMock(result: nil)
    ) -> MainCalculatorViewModel {
        MainCalculatorViewModel(
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR")),
            productStore: productStore,
            settingsStore: settingsStore,
            productLookupService: productLookupService
        )
    }
}

private struct ProductLookupServiceMock: ProductLookupServicing {
    let result: ProductLookupResult?
    let error: Error?

    init(result: ProductLookupResult?) {
        self.result = result
        self.error = nil
    }

    init(error: Error) {
        self.result = nil
        self.error = error
    }

    func lookupProduct(barcode: Barcode) async throws -> ProductLookupResult? {
        if let error {
            throw error
        }

        return result
    }
}
