//
//  ProductRecapViewModel.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Combine
import Foundation

struct ProductCategorySection: Identifiable, Equatable {
    let category: Category?
    let products: [Product]

    var id: String {
        category?.id ?? "uncategorized"
    }

    var title: String {
        category?.name ?? "Sans categorie"
    }

    var totalOriginalPrice: Decimal {
        products.reduce(0) { $0 + $1.originalPrice }
    }

    var totalFinalPrice: Decimal {
        products.reduce(0) { $0 + $1.finalPrice }
    }

    var totalDiscountAmount: Decimal {
        products.reduce(0) { $0 + $1.discountAmount }
    }
}

@MainActor
final class ProductRecapViewModel: ObservableObject {
    @Published private(set) var products: [Product]

    private let productStore: ProductStore
    private let moneyFormatter: MoneyFormatter
    private var cancellables = Set<AnyCancellable>()

    var categorySections: [ProductCategorySection] {
        let groupedProducts = Dictionary(grouping: products) { product in
            product.category
        }

        return groupedProducts
            .map { ProductCategorySection(category: $0.key, products: $0.value) }
            .sorted { $0.title < $1.title }
    }

    var totalOriginalPrice: Decimal {
        products.reduce(0) { $0 + $1.originalPrice }
    }

    var totalFinalPrice: Decimal {
        products.reduce(0) { $0 + $1.finalPrice }
    }

    var totalDiscountAmount: Decimal {
        products.reduce(0) { $0 + $1.discountAmount }
    }

    var formattedTotalOriginalPrice: String {
        moneyFormatter.formatCurrency(totalOriginalPrice)
    }

    var formattedTotalFinalPrice: String {
        moneyFormatter.formatCurrency(totalFinalPrice)
    }

    var formattedTotalDiscountAmount: String {
        moneyFormatter.formatCurrency(totalDiscountAmount)
    }

    func formattedTotalFinalPrice(for section: ProductCategorySection) -> String {
        moneyFormatter.formatCurrency(section.totalFinalPrice)
    }

    func formattedDiscountAmount(for section: ProductCategorySection) -> String {
        moneyFormatter.formatCurrency(section.totalDiscountAmount)
    }

    func formattedFinalPrice(for product: Product) -> String {
        moneyFormatter.formatCurrency(product.finalPrice)
    }

    init(
        productStore: ProductStore? = nil,
        moneyFormatter: MoneyFormatter = MoneyFormatter()
    ) {
        let productStore = productStore ?? ProductStore()

        self.productStore = productStore
        self.moneyFormatter = moneyFormatter
        self.products = productStore.products

        observeProducts()
    }

    func remove(_ product: Product) {
        productStore.remove(product)
    }

    func clear() {
        productStore.clear()
    }
}

private extension ProductRecapViewModel {
    func observeProducts() {
        productStore.$products
            .sink { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)
    }
}
