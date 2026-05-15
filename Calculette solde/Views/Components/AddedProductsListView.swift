import SwiftUI

struct AddedProductsListView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @ObservedObject var viewModel: MainCalculatorViewModel
    let productStore: ProductStore?
    @State private var productBeingCategorized: Product?
    @State private var isClearConfirmationPresented = false
    @State private var isPremiumSheetPresented = false

    init(viewModel: MainCalculatorViewModel, productStore: ProductStore? = nil) {
        self.viewModel = viewModel
        self.productStore = productStore
    }

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
                    isPremiumActive: premiumManager.isPremiumActive,
                    onSelect: { category in
                        viewModel.assignCategory(category, to: product)
                    },
                    onRequestPremium: {
                        productBeingCategorized = nil
                        isPremiumSheetPresented = true
                    },
                    onAddCustomCategory: { name in
                        viewModel.addCustomCategory(named: name)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isPremiumSheetPresented) {
                PremiumUpgradeView(premiumManager: premiumManager)
            }
            .alert("Vider la liste ?", isPresented: $isClearConfirmationPresented) {
                Button("Annuler", role: .cancel) {}
                Button("Vider", role: .destructive) {
                    withAnimation {
                        viewModel.clearSavedProducts()
                    }
                }
            } message: {
                Text("Tous les produits ajoutés seront supprimés.")
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

            if let productStore {
                NavigationLink {
                    ProductRecapView(
                        viewModel: ProductRecapViewModel(productStore: productStore)
                    )
                } label: {
                    Image(systemName: "chart.pie.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Récapitulatif")
            }

            Button {
                isClearConfirmationPresented = true
            } label: {
                Image(systemName: "trash")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Vider la liste")
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
        .environmentObject(PremiumManager())
}
