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
    @Published private(set) var isLookingUpScannedProduct: Bool
    @Published private(set) var productLookupErrorMessage: String?

    @Published private(set) var originalPrice: Decimal?
    @Published private(set) var discountAmount: Decimal?
    @Published private(set) var finalPrice: Decimal?
    @Published private(set) var isOverBudget: Bool
    @Published private(set) var errorMessage: String?
    @Published private(set) var savedProducts: [Product]

    let availableDiscountRates: [DiscountRate]
    @Published private(set) var availableCategories: [Category]

    private let calculator: DiscountCalculator
    private let moneyFormatter: MoneyFormatter
    private let productStore: ProductStore
    private let settingsStore: SettingsStore
    private let productLookupService: ProductLookupServicing
    private let categoryStore: CategoryStore
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

    var savedProductsTotal: Decimal {
        savedProducts.reduce(Decimal(0)) { $0 + $1.finalPrice }
    }

    var formattedSavedProductsTotal: String {
        moneyFormatter.formatCurrency(savedProductsTotal)
    }

    var hasMaximumBudget: Bool {
        settings.hasMaximumBudget
    }

    var maximumBudget: Decimal? {
        settings.maximumBudget
    }

    var formattedMaximumBudget: String {
        moneyFormatter.formatCurrency(maximumBudget)
    }

    var budgetProgress: Double {
        guard let maximumBudget, maximumBudget > 0 else { return 0 }
        let total = NSDecimalNumber(decimal: savedProductsTotal).doubleValue
        let budget = NSDecimalNumber(decimal: maximumBudget).doubleValue
        return min(max(total / budget, 0), 1)
    }

    var budgetRemaining: Decimal? {
        guard let maximumBudget else { return nil }
        return maximumBudget - savedProductsTotal
    }

    var formattedBudgetRemaining: String {
        moneyFormatter.formatCurrency(budgetRemaining.map { max($0, 0) })
    }

    var formattedBudgetExceededAmount: String {
        guard let budgetRemaining, budgetRemaining < 0 else { return moneyFormatter.formatCurrency(Decimal(0)) }
        return moneyFormatter.formatCurrency(abs(budgetRemaining))
    }

    var scannedBarcodeValue: String? {
        scannedBarcode?.value
    }

    var scannedBarcodeSymbologyLabel: String? {
        scannedBarcode?.symbology.displayName
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
        categoryStore: CategoryStore? = nil,
        calculator: DiscountCalculator = DiscountCalculator(),
        moneyFormatter: MoneyFormatter = MoneyFormatter(),
        productStore: ProductStore? = nil,
        settingsStore: SettingsStore? = nil,
        productLookupService: ProductLookupServicing = ProductLookupService()
    ) {
        let productStore = productStore ?? ProductStore()
        let settingsStore = settingsStore ?? SettingsStore()
        let categoryStore = categoryStore ?? CategoryStore()

        self.productName = productName
        self.originalPriceText = originalPriceText
        self.customDiscountText = customDiscountText
        self.selectedDiscountRate = selectedDiscountRate
        self.selectedCategory = selectedCategory
        self.scannedBarcode = scannedBarcode
        self.productLookupResult = productLookupResult
        self.availableDiscountRates = availableDiscountRates
        self.availableCategories = categoryStore.allCategories
        self.categoryStore = categoryStore
        self.calculator = calculator
        self.moneyFormatter = moneyFormatter
        self.productStore = productStore
        self.settingsStore = settingsStore
        self.productLookupService = productLookupService
        self.settings = settingsStore.settings
        self.isOverBudget = false
        self.isLookingUpScannedProduct = false
        self.productLookupErrorMessage = nil
        self.savedProducts = productStore.products

        updateBudgetState()
        enforceSettings()
        observeSettings()
        observeProducts()
        observeCategories()
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
    }

    @discardableResult
    func saveCurrentProduct() -> Bool {
        calculate()

        guard let currentProduct else {
            errorMessage = "Aucun produit valide a enregistrer."
            return false
        }

        guard currentProduct.originalPrice > 0 else {
            errorMessage = "Renseignez un prix supérieur à 0 € pour ajouter ce produit."
            return false
        }

        productStore.add(currentProduct)
        reset()
        return true
    }

    func removeSavedProduct(_ product: Product) {
        productStore.remove(product)
    }

    func clearSavedProducts() {
        productStore.clear()
    }

    func assignCategory(_ category: Category?, to product: Product) {
        productStore.updateCategory(category, for: product)
    }

    func addCustomCategory(named name: String) -> Category? {
        categoryStore.addCustomCategory(named: name)
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
        productLookupErrorMessage = nil
    }

    func handleScannedBarcode(_ barcode: Barcode) {
        updateScannedBarcode(barcode)

        Task {
            await lookupScannedProduct(for: barcode)
        }
    }

    func clearScanState() {
        scannedBarcode = nil
        productLookupResult = nil
        productLookupErrorMessage = nil
        isLookingUpScannedProduct = false
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

    func lookupScannedProduct(for barcode: Barcode) async {
        scannedBarcode = barcode
        isLookingUpScannedProduct = true
        productLookupErrorMessage = nil

        do {
            guard let result = try await productLookupService.lookupProduct(barcode: barcode) else {
                productLookupResult = nil
                productLookupErrorMessage = "Produit introuvable pour ce code-barres."
                isLookingUpScannedProduct = false
                return
            }

            applyLookupResult(result)
            isLookingUpScannedProduct = false
        } catch ProductLookupError.invalidBarcode {
            productLookupErrorMessage = "Code-barres invalide."
            isLookingUpScannedProduct = false
        } catch {
            productLookupErrorMessage = "Impossible de récupérer les informations du produit."
            isLookingUpScannedProduct = false
        }
    }
}

private extension Barcode.Symbology {
    var displayName: String {
        switch self {
        case .ean8:
            return "EAN-8"
        case .ean13:
            return "EAN-13"
        case .upcA:
            return "UPC-A"
        case .upcE:
            return "UPC-E"
        case .isbn:
            return "ISBN"
        case .gtin:
            return "GTIN"
        case .unknown:
            return "Code-barres"
        }
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
                guard let self else { return }
                self.savedProducts = products
                self.updateBudgetState()
            }
            .store(in: &cancellables)
    }

    func observeCategories() {
        categoryStore.$customCategories
            .sink { [weak self] _ in
                guard let self else { return }
                self.availableCategories = self.categoryStore.allCategories
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
        guard settings.hasMaximumBudget else {
            isOverBudget = false
            return
        }

        isOverBudget = !settings.isWithinBudget(savedProductsTotal)
    }

    func clearCalculation(keepingOriginalPrice originalPrice: Decimal? = nil) {
        self.originalPrice = originalPrice
        discountAmount = nil
        finalPrice = nil
    }

    func matchingCategory(named categoryName: String?) -> Category? {
        guard let normalizedCategoryName = categoryName?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
            !normalizedCategoryName.isEmpty
        else {
            return nil
        }

        let aliases = [
            "courses": "groceries",
            "course": "groceries",
            "alimentation": "groceries",
            "food": "groceries",
            "vetements": "clothing",
            "vêtements": "clothing",
            "vetement": "clothing",
            "vêtement": "clothing"
        ]
        let resolvedCategoryName = aliases[normalizedCategoryName] ?? normalizedCategoryName

        return availableCategories.first { category in
            category.id.lowercased() == resolvedCategoryName ||
                category.name.lowercased() == resolvedCategoryName
        }
    }
}
