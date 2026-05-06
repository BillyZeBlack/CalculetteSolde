//
//  ProductLookupService.swift
//  Calculette solde
//
//  Created by Williams SAADI on 05/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

protocol ProductLookupServicing {
    func lookupProduct(barcode: Barcode) async throws -> ProductLookupResult?
}

enum ProductLookupError: Error, Equatable {
    case invalidBarcode
    case invalidResponse
}

struct ProductLookupService: ProductLookupServicing {
    private let session: URLSession
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://world.openfoodfacts.org")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    func lookupProduct(barcode: Barcode) async throws -> ProductLookupResult? {
        guard barcode.isValid else {
            throw ProductLookupError.invalidBarcode
        }

        var components = URLComponents(
            url: baseURL.appendingPathComponent("api/v2/product/\(barcode.value).json"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(
                name: "fields",
                value: [
                    "product_name",
                    "product_name_fr",
                    "generic_name",
                    "brands",
                    "categories",
                    "categories_tags",
                    "image_url"
                ].joined(separator: ",")
            )
        ]

        guard let url = components?.url else {
            throw ProductLookupError.invalidBarcode
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("SoldeFacile-iOS/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw ProductLookupError.invalidResponse
        }

        let payload = try JSONDecoder().decode(OpenFoodFactsProductResponse.self, from: data)

        guard payload.status == 1, let product = payload.product else {
            return nil
        }

        let name = product.bestName
        guard !name.isEmpty else {
            return nil
        }

        return ProductLookupResult(
            barcode: barcode,
            source: .openFoodFacts,
            name: name,
            brand: product.brands?.nilIfBlank,
            categoryName: product.bestCategoryName,
            imageURL: product.imageURL
        )
    }
}

private struct OpenFoodFactsProductResponse: Decodable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

private struct OpenFoodFactsProduct: Decodable {
    let productName: String?
    let productNameFR: String?
    let genericName: String?
    let brands: String?
    let categories: String?
    let categoriesTags: [String]?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productNameFR = "product_name_fr"
        case genericName = "generic_name"
        case brands
        case categories
        case categoriesTags = "categories_tags"
        case imageURL = "image_url"
    }

    var bestName: String {
        productNameFR?.nilIfBlank ??
            productName?.nilIfBlank ??
            genericName?.nilIfBlank ??
            ""
    }

    var bestCategoryName: String? {
        categories?.split(separator: ",").first.map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }?.nilIfBlank ??
            categoriesTags?.first?.replacingOccurrences(of: "en:", with: "").nilIfBlank
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
