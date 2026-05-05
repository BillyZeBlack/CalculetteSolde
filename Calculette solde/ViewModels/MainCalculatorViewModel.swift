//
//  MainCalculatorViewModel.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class MainCalculatorViewModel: ObservableObject {
    @Published var productName: String
    @Published var originalPriceText: String
    @Published var customDiscountText: String
    @Published private(set) var selectedDiscountRate: DiscountRate?
    @Published var selectedCategory: Category?
    @Published private(set) var settings: AppSettings

    @Published var scannedBarcode: Barcode?
    @Published var productLookupResult: ProductLookupResult?

    @Published private(set) var originalPrice: Decimal?
    @Published private(set) var discountAmount: Decimal?
    @Published private(set) var finalPrice: Decimal?
    @Published private(set) var isOverBudget: Bool
    @Published private(set) var errorMessage: String?
    @Published private(set) var savedProducts: [Product]

    let availableDiscountRates: [DiscountRate]
    let availableCategories: [Category]

    private let calculator: DiscountCalculator
    private let moneyFormatter: MoneyFormatter
    private let productStore: ProductStore
    private let settingsStore: SettingsStore
    private var cancellables = Set<AnyCancellable>()

    var canSelectCategory: Bool {
        settings.allowsCategorySelection
    }

    var currentProduct: Product? {
        guard let originalPrice else { return nil }

        return Product(
            name: normalizedProductName,
            originalPrice: originalPrice,
            discountRate: selectedDiscountRate,
            category: canSelectCategory ? selectedCategory : nil
        )
    }

    var formattedOriginalPrice: String {
        moneyFormatter.formatCurrency(originalPrice)
    }

    var formattedDiscountAmount: String {
        moneyFormatter.formatCurrency(discountAmount)
    }

    var formattedFinalPrice: String {
        moneyFormatter.formatCurrency(finalPrice)
    }

    var currencySymbol: String {
        moneyFormatter.currencySymbol
    }

    var formattedSavedProductsTotal: String {
        let total = savedProducts.reduce(Decimal(0)) { $0 + $1.finalPrice }
        return moneyFormatter.formatCurrency(total)
    }

    func formattedFinalPrice(for product: Product) -> String {
        moneyFormatter.formatCurrency(product.finalPrice)
    }

    init(
        productName: String = "",
        originalPriceText: String = "",
        customDiscountText: String = "",
        selectedDiscountRate: DiscountRate? = nil,
        selectedCategory: Category? = nil,
        scannedBarcode: Barcode? = nil,
        productLookupResult: ProductLookupResult? = nil,
        availableDiscountRates: [DiscountRate] = DiscountRate.standardRates,
        availableCategories: [Category] = Category.defaults,
        calculator: DiscountCalculator = DiscountCalculator(),
        moneyFormatter: MoneyFormatter = MoneyFormatter(),
        productStore: ProductStore? = nil,
        settingsStore: SettingsStore? = nil
    ) {
        let productStore = productStore ?? ProductStore()
        let settingsStore = settingsStore ?? SettingsStore()

        self.productName = productName
        self.originalPriceText = originalPriceText
        self.customDiscountText = customDiscountText
        self.selectedDiscountRate = selectedDiscountRate
        self.selectedCategory = selectedCategory
        self.scannedBarcode = scannedBarcode
        self.productLookupResult = productLookupResult
        self.availableDiscountRates = availableDiscountRates
        self.availableCategories = availableCategories
        self.calculator = calculator
        self.moneyFormatter = moneyFormatter
        self.productStore = productStore
        self.settingsStore = settingsStore
        self.settings = settingsStore.settings
        self.isOverBudget = false
        self.savedProducts = productStore.products

        enforceSettings()
        observeSettings()
        observeProducts()
    }

    func selectDiscountRate(_ rate: DiscountRate) {
        selectedDiscountRate = rate
        customDiscountText = ""
    }

    func clearDiscountSelection() {
        selectedDiscountRate = nil
        customDiscountText = ""
    }

    func clearSelectedDiscountRate() {
        selectedDiscountRate = nil
    }

    func calculate() {
        errorMessage = nil
        enforceSettings()

        let trimmedOriginalPriceText = originalPriceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOriginalPriceText.isEmpty else {
            clearCalculation()
            return
        }

        guard let originalPrice = moneyFormatter.parseDecimal(originalPriceText), originalPrice >= 0 else {
            clearCalculation()
            errorMessage = "Le prix initial est invalide."
            return
        }

        guard let discountRate = parseDiscountRate() else {
            clearCalculation(keepingOriginalPrice: originalPrice)
            return
        }

        let result = calculator.calculate(
            originalPrice: originalPrice,
            discountRate: discountRate
        )

        self.originalPrice = result.originalPrice
        self.selectedDiscountRate = result.discountRate
        discountAmount = result.discountAmount
        finalPrice = result.finalPrice
        updateBudgetState()
    }

    func saveCurrentProduct() {
        guard let currentProduct else {
            errorMessage = "Aucun produit valide a enregistrer."
            return
        }

        productStore.add(currentProduct)
        errorMessage = nil
    }

    func removeSavedProduct(_ product: Product) {
        productStore.remove(product)
    }

    func applyLookupResult(_ result: ProductLookupResult) {
        productLookupResult = result
        scannedBarcode = result.barcode
        productName = result.name

        guard canSelectCategory, selectedCategory == nil else { return }
        selectedCategory = matchingCategory(named: result.categoryName)
    }

    func updateScannedBarcode(_ barcode: Barcode) {
        scannedBarcode = barcode
        productLookupResult = nil
    }

    func clearScanState() {
        scannedBarcode = nil
        productLookupResult = nil
    }

    func reset() {
        productName = ""
        originalPriceText = ""
        customDiscountText = ""
        selectedDiscountRate = nil
        selectedCategory = nil
        scannedBarcode = nil
        productLookupResult = nil
        clearCalculation()
    }
}

private extension MainCalculatorViewModel {
    var normalizedProductName: String {
        let trimmedName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            return trimmedName
        }

        return productLookupResult?.name ?? ""
    }

    func observeSettings() {
        settingsStore.$settings
            .sink { [weak self] settings in
                guard let self else { return }
                self.settings = settings
                self.enforceSettings()
                self.updateBudgetState()
            }
            .store(in: &cancellables)
    }

    func observeProducts() {
        productStore.$products
            .sink { [weak self] products in
                self?.savedProducts = products
            }
            .store(in: &cancellables)
    }

    func parseDiscountRate() -> DiscountRate? {
        let trimmedCustomDiscount = customDiscountText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCustomDiscount.isEmpty else {
            return selectedDiscountRate ?? DiscountRate(percentage: 0)
        }

        guard let value = moneyFormatter.parseDecimal(trimmedCustomDiscount), value >= 0, value <= 100 else {
            errorMessage = "La remise personnalisee doit etre comprise entre 0 et 100."
            return nil
        }

        guard let percentage = moneyFormatter.wholeNumber(from: value) else {
            errorMessage = "La remise personnalisee doit etre un nombre entier."
            return nil
        }

        return DiscountRate(percentage: percentage)
    }

    func enforceSettings() {
        if !settings.allowsCategorySelection {
            selectedCategory = nil
        }
    }

    func updateBudgetState() {
        guard let finalPrice, settings.hasMaximumBudget else {
            isOverBudget = false
            clearBudgetErrorIfNeeded()
            return
        }

        isOverBudget = !settings.isWithinBudget(finalPrice)

        if isOverBudget {
            errorMessage = "Le prix final depasse le budget maximum."
        } else {
            clearBudgetErrorIfNeeded()
        }
    }

    func clearCalculation(keepingOriginalPrice originalPrice: Decimal? = nil) {
        self.originalPrice = originalPrice
        discountAmount = nil
        finalPrice = nil
        isOverBudget = false
    }

    func clearBudgetErrorIfNeeded() {
        if errorMessage == "Le prix final depasse le budget maximum." {
            errorMessage = nil
        }
    }

    func matchingCategory(named categoryName: String?) -> Category? {
        guard let normalizedCategoryName = categoryName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
            !normalizedCategoryName.isEmpty
        else {
            return nil
        }

        return availableCategories.first { category in
            category.id.lowercased() == normalizedCategoryName ||
                category.name.lowercased() == normalizedCategoryName
        }
    }
}
