//
//  ProductLookupSource.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

enum ProductLookupSource: String, Equatable, Hashable {
    case openFoodFacts
    case upcItemDB
    case manual
    case unknown

    var displayName: String {
        switch self {
        case .openFoodFacts:
            return "Open Food Facts"
        case .upcItemDB:
            return "UPCitemdb"
        case .manual:
            return "Saisie manuelle"
        case .unknown:
            return "Source inconnue"
        }
    }
}
