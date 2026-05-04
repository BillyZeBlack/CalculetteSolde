//
//  Barcode.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

struct Barcode: Identifiable, Equatable, Hashable {
    enum Symbology: String, Equatable, Hashable {
        case ean8
        case ean13
        case upcA
        case upcE
        case isbn
        case gtin
        case unknown
    }

    let value: String
    let symbology: Symbology

    var id: String {
        "\(symbology.rawValue):\(value)"
    }

    init(value: String, symbology: Symbology = .unknown) {
        self.value = value.filter { $0.isNumber }
        self.symbology = symbology
    }

    var isValid: Bool {
        switch symbology {
        case .ean8:
            return value.count == 8
        case .ean13, .upcA:
            return value.count == 12 || value.count == 13
        case .upcE:
            return value.count == 6 || value.count == 8
        case .isbn:
            return value.count == 10 || value.count == 13
        case .gtin:
            return (8...14).contains(value.count)
        case .unknown:
            return (6...14).contains(value.count)
        }
    }
}
