import SwiftUI

struct AddedProductsListView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel
    @State private var productBeingCategorized: Product?

    private let rowHeight: CGFloat = 64
    private let maximumVisibleRows = 4

    var body: some View {
        if !viewModel.savedProducts.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                header

                List {
                    ForEach(viewModel.savedProducts) { product in
                        ProductRowView(
                            product: product,
                            finalPrice: viewModel.formattedFinalPrice(for: product),
                            onCategoryTap: {
                                productBeingCategorized = product
                            }
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.visible)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel.removeSavedProduct(product)
                                }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollDisabled(viewModel.savedProducts.count <= maximumVisibleRows)
                .frame(height: listHeight)
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .sheet(item: $productBeingCategorized) { product in
                CategorySelectionView(
                    product: product,
                    categories: viewModel.availableCategories,
                    onSelect: { category in
                        viewModel.assignCategory(category, to: product)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var header: some View {
        HStack {
            Label("Produits ajoutés", systemImage: "list.bullet.rectangle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Text(viewModel.formattedSavedProductsTotal)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private var listHeight: CGFloat {
        let visibleRows = min(viewModel.savedProducts.count, maximumVisibleRows)
        return CGFloat(visibleRows) * rowHeight
    }
}

private struct ProductRowView: View {
    let product: Product
    let finalPrice: String
    let onCategoryTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCategoryTap) {
                Image(systemName: product.category?.systemImageName ?? "cart.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choisir une catégorie")

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name.isEmpty ? "Produit sans nom" : product.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(product.discountRate?.label ?? "0%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Text(finalPrice)
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .frame(height: 64)
        .contentShape(Rectangle())
    }
}

#Preview {
    AddedProductsListView(viewModel: MainCalculatorViewModel())
}
