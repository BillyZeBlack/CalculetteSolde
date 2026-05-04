//
//  ProductLookupResult.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct ProductLookupResult: Identifiable, Equatable, Hashable {
    let id: UUID
    let barcode: Barcode
    let source: ProductLookupSource
    var name: String
    var brand: String?
    var categoryName: String?
    var imageURL: URL?
    var fetchedAt: Date

    init(
        id: UUID = UUID(),
        barcode: Barcode,
        source: ProductLookupSource,
        name: String,
        brand: String? = nil,
        categoryName: String? = nil,
        imageURL: URL? = nil,
        fetchedAt: Date = Date()
    ) {
        self.id = id
        self.barcode = barcode
        self.source = source
        self.name = name
        self.brand = brand
        self.categoryName = categoryName
        self.imageURL = imageURL
        self.fetchedAt = fetchedAt
    }

    func makeProduct(
        originalPrice: Decimal = 0,
        discountRate: DiscountRate? = nil,
        category: Category? = nil
    ) -> Product {
        Product(
            name: name,
            originalPrice: originalPrice,
            discountRate: discountRate,
            category: category
        )
    }
}
