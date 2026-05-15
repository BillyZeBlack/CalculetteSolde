//
//  SettingsStore.swift
//  Calculette solde
//
//  Created by Williams SAADI on 04/05/2026.
//  Copyright © 2026 williams saadi. All rights reserved.
//

import Combine
import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { saveSettingsIfNeeded() }
    }

    private let persistsSettings: Bool
    private let userDefaults: UserDefaults
    private let storageKey = "appSettings"

    init(
        settings: AppSettings = .default,
        persistsSettings: Bool = false,
        userDefaults: UserDefaults = .standard
    ) {
        self.persistsSettings = persistsSettings
        self.userDefaults = userDefaults

        if persistsSettings, let storedSettings = Self.loadSettings(from: userDefaults, key: storageKey) {
            self.settings = storedSettings
        } else {
            self.settings = settings
        }
    }
}

private extension SettingsStore {
    static func loadSettings(from userDefaults: UserDefaults, key: String) -> AppSettings? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AppSettings.self, from: data)
    }

    func saveSettingsIfNeeded() {
        guard persistsSettings, let data = try? JSONEncoder().encode(settings) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
