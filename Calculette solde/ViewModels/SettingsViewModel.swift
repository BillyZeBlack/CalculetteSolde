//
//  SettingsViewModel.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var maximumBudgetText: String
    @Published var allowsCategorySelection: Bool
    @Published private(set) var errorMessage: String?

    private let settingsStore: SettingsStore
    private let moneyFormatter: MoneyFormatter
    private var cancellables = Set<AnyCancellable>()

    var settings: AppSettings {
        settingsStore.settings
    }

    init(
        settingsStore: SettingsStore? = nil,
        moneyFormatter: MoneyFormatter = MoneyFormatter()
    ) {
        let settingsStore = settingsStore ?? SettingsStore()

        self.settingsStore = settingsStore
        self.moneyFormatter = moneyFormatter
        self.maximumBudgetText = settingsStore.settings.maximumBudget.map {
            moneyFormatter.formatCurrency($0)
        } ?? ""
        self.allowsCategorySelection = settingsStore.settings.allowsCategorySelection

        observeSettings()
    }

    func save() {
        errorMessage = nil

        let trimmedBudget = maximumBudgetText.trimmingCharacters(in: .whitespacesAndNewlines)
        let maximumBudget: Decimal?

        if trimmedBudget.isEmpty {
            maximumBudget = nil
        } else if let parsedBudget = moneyFormatter.parseDecimal(trimmedBudget), parsedBudget >= 0 {
            maximumBudget = parsedBudget
        } else {
            errorMessage = "Le budget maximum est invalide."
            return
        }

        settingsStore.settings = AppSettings(
            maximumBudget: maximumBudget,
            allowsCategorySelection: allowsCategorySelection
        )
    }

    func clearMaximumBudget() {
        maximumBudgetText = ""
    }
}

private extension SettingsViewModel {
    func observeSettings() {
        settingsStore.$settings
            .dropFirst()
            .sink { [weak self] settings in
                guard let self else { return }
                self.maximumBudgetText = settings.maximumBudget.map {
                    self.moneyFormatter.formatCurrency($0)
                } ?? ""
                self.allowsCategorySelection = settings.allowsCategorySelection
            }
            .store(in: &cancellables)
    }
}
