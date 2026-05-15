import SwiftUI

struct CategorySelectionView: View {
    let product: Product
    let categories: [Category]
    let isPremiumActive: Bool
    let onSelect: (Category?) -> Void
    let onRequestPremium: () -> Void
    let onAddCustomCategory: (String) -> Category?

    @Environment(\.dismiss) private var dismiss
    @State private var isCustomCategoryAlertPresented = false
    @State private var customCategoryName = ""

    private var freeCategories: [Category] {
        categories.filter { !$0.isPremium }
    }

    private var premiumCategories: [Category] {
        categories.filter { $0.isPremium && !$0.isCustom }
    }

    private var customCategories: [Category] {
        categories.filter(\.isCustom)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        onSelect(nil)
                        dismiss()
                    } label: {
                        categoryRow(
                            category: nil,
                            name: "Aucune catégorie",
                            systemImageName: "nosign",
                            isSelected: product.category == nil,
                            isLocked: false
                        )
                    }
                    .foregroundStyle(.primary)
                }

                Section("Gratuit") {
                    ForEach(freeCategories) { category in
                        categoryButton(for: category)
                    }
                }

                Section("Premium") {
                    ForEach(premiumCategories) { category in
                        categoryButton(for: category)
                    }
                }

                if !customCategories.isEmpty {
                    Section("Personnalisées") {
                        ForEach(customCategories) { category in
                            categoryButton(for: category)
                        }
                    }
                }

                Section {
                    Button {
                        guard isPremiumActive else {
                            onRequestPremium()
                            return
                        }
                        customCategoryName = ""
                        isCustomCategoryAlertPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.blue)
                                .frame(width: 30, height: 30)
                                .background(Color.blue.opacity(0.1), in: Circle())

                            Text("Ajouter une catégorie")
                                .font(.body)

                            Spacer()

                            if !isPremiumActive {
                                Label("Premium", systemImage: "lock.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Choisir une catégorie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
            .alert("Nouvelle catégorie", isPresented: $isCustomCategoryAlertPresented) {
                TextField("Nom", text: $customCategoryName)
                Button("Annuler", role: .cancel) {}
                Button("Ajouter") {
                    guard let category = onAddCustomCategory(customCategoryName) else { return }
                    onSelect(category)
                    dismiss()
                }
            } message: {
                Text("Créez une catégorie personnalisée disponible à chaque ouverture de l’app.")
            }
        }
    }

    private func categoryButton(for category: Category) -> some View {
        let isLocked = category.isPremium && !isPremiumActive

        return Button {
            guard !isLocked else {
                onRequestPremium()
                return
            }

            onSelect(category)
            dismiss()
        } label: {
            categoryRow(
                category: category,
                name: category.name,
                systemImageName: category.systemImageName,
                isSelected: product.category == category,
                isLocked: isLocked
            )
        }
        .foregroundStyle(.primary)
    }

    private func categoryRow(
        category: Category?,
        name: String,
        systemImageName: String,
        isSelected: Bool,
        isLocked: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImageName)
                .font(.body.weight(.semibold))
                .foregroundStyle(isLocked ? Color.secondary : Color.blue)
                .frame(width: 30, height: 30)
                .background((isLocked ? Color.secondary : Color.blue).opacity(0.1), in: Circle())

            Text(name)
                .font(.body)
                .foregroundStyle(isLocked ? .secondary : .primary)

            Spacer()

            if isLocked {
                Label("Premium", systemImage: "lock.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    CategorySelectionView(
        product: Product(
            name: "Pull",
            originalPrice: Decimal(100),
            discountRate: DiscountRate(percentage: 30),
            category: Category.defaults[0]
        ),
        categories: Category.defaults,
        isPremiumActive: false,
        onSelect: { _ in },
        onRequestPremium: {},
        onAddCustomCategory: { _ in nil }
    )
}
