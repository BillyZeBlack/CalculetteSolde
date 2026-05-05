//
//  ProductStore.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class ProductStore: ObservableObject {
    @Published private(set) var products: [Product]

    init(products: [Product] = []) {
        self.products = products
    }

    func add(_ product: Product) {
        products.append(product)
    }

    func remove(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }

    func updateCategory(_ category: Category?, for product: Product) {
        guard let index = products.firstIndex(where: { $0.id == product.id }) else { return }
        products[index].category = category
    }

    func clear() {
        products.removeAll()
    }
}
