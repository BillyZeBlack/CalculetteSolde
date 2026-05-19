import Combine
import Foundation

@MainActor
final class CategoryStore: ObservableObject {
    @Published private(set) var customCategories: [Category] {
        didSet { saveCustomCategories() }
    }

    private let storageKey = "com.slideofdigital.Calculette-solde.customCategories"
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(customCategories: [Category]? = nil, userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.customCategories = customCategories ?? Self.loadCustomCategories(
            storageKey: storageKey,
            userDefaults: userDefaults,
            decoder: decoder
        )
    }

    var allCategories: [Category] {
        Category.defaults + customCategories
    }

    @discardableResult
    func addCustomCategory(named rawName: String) -> Category? {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return nil }

        let duplicate = allCategories.contains {
            $0.name.compare(name, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
        }
        guard !duplicate else { return nil }

        let category = Category(
            id: "custom-\(UUID().uuidString.lowercased())",
            name: name,
            systemImageName: "tag",
            isPremium: true,
            isCustom: true
        )
        customCategories.append(category)
        return category
    }

    @discardableResult
    func removeCustomCategory(_ category: Category) -> Bool {
        guard category.isCustom,
              customCategories.contains(where: { $0.id == category.id })
        else {
            return false
        }

        customCategories.removeAll { $0.id == category.id }
        return true
    }

    private func saveCustomCategories() {
        guard let data = try? encoder.encode(customCategories) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    private static func loadCustomCategories(
        storageKey: String,
        userDefaults: UserDefaults,
        decoder: JSONDecoder
    ) -> [Category] {
        guard let data = userDefaults.data(forKey: storageKey),
              let categories = try? decoder.decode([Category].self, from: data)
        else {
            return []
        }

        return categories
    }
}
