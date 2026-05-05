import SwiftUI

struct CategorySelectionView: View {
    let product: Product
    let categories: [Category]
    let onSelect: (Category?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSelect(nil)
                    dismiss()
                } label: {
                    categoryRow(
                        name: "Aucune catégorie",
                        systemImageName: "nosign",
                        isSelected: product.category == nil
                    )
                }
                .foregroundStyle(.primary)

                ForEach(categories) { category in
                    Button {
                        onSelect(category)
                        dismiss()
                    } label: {
                        categoryRow(
                            name: category.name,
                            systemImageName: category.systemImageName,
                            isSelected: product.category == category
                        )
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
        }
    }

    private func categoryRow(
        name: String,
        systemImageName: String,
        isSelected: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImageName)
                .font(.body.weight(.semibold))
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.1), in: Circle())

            Text(name)
                .font(.body)

            Spacer()

            if isSelected {
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
        onSelect: { _ in }
    )
}
