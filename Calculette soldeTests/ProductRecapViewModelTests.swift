//
//  ProductRecapViewModelTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

@MainActor
final class ProductRecapViewModelTests: XCTestCase {
    func testTracksSharedProductStore() {
        let store = ProductStore()
        let viewModel = ProductRecapViewModel(
            productStore: store,
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR"))
        )

        store.add(makeProduct(name: "Pull", price: 100, discount: 40, category: Calculette_solde.Category.defaults[0]))

        XCTAssertEqual(viewModel.products.count, 1)
        XCTAssertEqual(viewModel.totalOriginalPrice, Decimal(100))
        XCTAssertEqual(viewModel.totalDiscountAmount, Decimal(40))
        XCTAssertEqual(viewModel.totalFinalPrice, Decimal(60))
    }

    func testBuildsCategorySections() {
        let store = ProductStore()
        let clothing = Calculette_solde.Category.defaults[0]
        let groceries = Calculette_solde.Category.defaults.first { $0.id == "groceries" }!
        let viewModel = ProductRecapViewModel(productStore: store)

        store.add(makeProduct(name: "Pull", price: 100, discount: 20, category: clothing))
        store.add(makeProduct(name: "Pates", price: 10, discount: 0, category: groceries))
        store.add(makeProduct(name: "Divers", price: 5, discount: 0, category: nil))

        XCTAssertEqual(viewModel.categorySections.count, 3)
        XCTAssertEqual(viewModel.categorySections.map(\.title), ["Courses", "Sans categorie", "Vetements"])
        XCTAssertEqual(viewModel.categorySections.first { $0.title == "Vetements" }?.totalFinalPrice, Decimal(80))
    }

    func testRemoveAndClearUseSharedStore() {
        let store = ProductStore()
        let product = makeProduct(name: "Pull", price: 100, discount: 20, category: nil)
        let viewModel = ProductRecapViewModel(productStore: store)

        store.add(product)
        viewModel.remove(product)

        XCTAssertTrue(store.products.isEmpty)
        XCTAssertTrue(viewModel.products.isEmpty)

        store.add(product)
        viewModel.clear()

        XCTAssertTrue(store.products.isEmpty)
        XCTAssertTrue(viewModel.products.isEmpty)
    }

    private func makeProduct(
        name: String,
        price: Decimal,
        discount: Int,
        category: Calculette_solde.Category?
    ) -> Product {
        Product(
            name: name,
            originalPrice: price,
            discountRate: DiscountRate(percentage: discount),
            category: category
        )
    }
}
