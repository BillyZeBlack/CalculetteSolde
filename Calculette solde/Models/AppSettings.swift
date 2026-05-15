//
//  AppSettings.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Foundation

struct AppSettings: Codable, Equatable, Hashable {
    var maximumBudget: Decimal?
    var allowsCategorySelection: Bool

    var hasMaximumBudget: Bool {
        maximumBudget != nil
    }

    init(maximumBudget: Decimal? = nil, allowsCategorySelection: Bool = true) {
        precondition(maximumBudget == nil || maximumBudget! >= 0, "Maximum budget must be greater than or equal to 0.")
        self.maximumBudget = maximumBudget
        self.allowsCategorySelection = allowsCategorySelection
    }

    func isWithinBudget(_ amount: Decimal) -> Bool {
        guard let maximumBudget else { return true }
        return amount <= maximumBudget
    }
}

extension AppSettings {
    static let `default` = AppSettings()
}
