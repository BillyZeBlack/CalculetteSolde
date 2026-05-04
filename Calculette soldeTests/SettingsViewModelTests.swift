//
//  SettingsViewModelTests.swift
//  Calculette soldeTests
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import XCTest
@testable import Calculette_solde

@MainActor
final class SettingsViewModelTests: XCTestCase {
    func testSavesMaximumBudgetAndCategorySetting() {
        let store = SettingsStore()
        let viewModel = SettingsViewModel(
            settingsStore: store,
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR"))
        )

        viewModel.maximumBudgetText = "150,50"
        viewModel.allowsCategorySelection = false
        viewModel.save()

        XCTAssertEqual(store.settings.maximumBudget, Decimal(string: "150.50"))
        XCTAssertFalse(store.settings.allowsCategorySelection)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testRejectsInvalidBudget() {
        let store = SettingsStore()
        let viewModel = SettingsViewModel(
            settingsStore: store,
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR"))
        )

        viewModel.maximumBudgetText = "abc"
        viewModel.allowsCategorySelection = false
        viewModel.save()

        XCTAssertEqual(store.settings, .default)
        XCTAssertEqual(viewModel.errorMessage, "Le budget maximum est invalide.")
    }

    func testEmptyBudgetDisablesBudgetLimit() {
        let store = SettingsStore(settings: AppSettings(maximumBudget: Decimal(100)))
        let viewModel = SettingsViewModel(
            settingsStore: store,
            moneyFormatter: MoneyFormatter(locale: Locale(identifier: "fr_FR"))
        )

        viewModel.clearMaximumBudget()
        viewModel.save()

        XCTAssertNil(store.settings.maximumBudget)
        XCTAssertTrue(store.settings.allowsCategorySelection)
    }
}
