import SwiftUI

struct AddedProductsListView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @ObservedObject var viewModel: MainCalculatorViewModel
    let productStore: ProductStore?
    let onBudgetSettingsTap: () -> Void
    @State private var productBeingCategorized: Product?
    @State private var isClearConfirmationPresented = false
    @State private var isPremiumSheetPresented = false
    @State private var premiumContext: PremiumPresentationContext = .general
    @State private var pendingPremiumContext: PremiumPresentationContext?

    init(
        viewModel: MainCalculatorViewModel,
        productStore: ProductStore? = nil,
        onBudgetSettingsTap: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.productStore = productStore
        self.onBudgetSettingsTap = onBudgetSettingsTap
    }

    private let rowHeight: CGFloat = 64
    private let maximumVisibleRows = 4

    var body: some View {
        if !viewModel.savedProducts.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                header
                budgetTracker

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
            .sheet(item: $productBeingCategorized, onDismiss: presentPendingPremiumIfNeeded) { product in
                CategorySelectionView(
                    product: product,
                    categories: viewModel.availableCategories,
                    isPremiumActive: premiumManager.isPremiumActive,
                    onSelect: { category in
                        viewModel.assignCategory(category, to: product)
                    },
                    onRequestPremium: {
                        pendingPremiumContext = .categories
                        productBeingCategorized = nil
                    },
                    onAddCustomCategory: { name in
                        viewModel.addCustomCategory(named: name)
                    }
                )
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isPremiumSheetPresented) {
                PremiumUpgradeView(
                    premiumManager: premiumManager,
                    context: premiumContext
                )
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

    @ViewBuilder
    private var budgetTracker: some View {
        if premiumManager.isPremiumActive {
            if viewModel.hasMaximumBudget {
                BudgetGaugeView(
                    total: viewModel.formattedSavedProductsTotal,
                    budget: viewModel.formattedMaximumBudget,
                    progress: viewModel.budgetProgress,
                    isOverBudget: viewModel.isOverBudget,
                    footer: budgetFooter,
                    action: onBudgetSettingsTap
                )
                .padding(.horizontal)
                .padding(.bottom, 12)
            } else {
                Button(action: onBudgetSettingsTap) {
                    HStack(spacing: 10) {
                        Image(systemName: "gauge.with.dots.needle.67percent")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)
                            .frame(width: 28, height: 28)
                            .background(Color.green.opacity(0.12), in: Circle())

                        Text("Définir un budget max")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        } else {
            Button {
                presentPremium(.budget)
            } label: {
                LockedBudgetPreviewView()
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }

    private var budgetFooter: String {
        if viewModel.isOverBudget {
            return "Dépassement de " + viewModel.formattedBudgetExceededAmount
        }

        return "Reste " + viewModel.formattedBudgetRemaining
    }

    private func presentPremium(_ context: PremiumPresentationContext) {
        premiumContext = context
        isPremiumSheetPresented = true
    }

    private func presentPendingPremiumIfNeeded() {
        guard let pendingPremiumContext else { return }
        self.pendingPremiumContext = nil
        presentPremium(pendingPremiumContext)
    }

    private var listHeight: CGFloat {
        let visibleRows = min(viewModel.savedProducts.count, maximumVisibleRows)
        return CGFloat(visibleRows) * rowHeight
    }
}

private struct BudgetGaugeView: View {
    let total: String
    let budget: String
    let progress: Double
    let isOverBudget: Bool
    let footer: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Budget", systemImage: isOverBudget ? "exclamationmark.triangle.fill" : "gauge.with.dots.needle.67percent")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isOverBudget ? .red : .secondary)

                    Spacer(minLength: 12)

                    Text(total + " / " + budget)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green, Color.yellow, Color.orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(proxy.size.width * progress, 6))
                    }
                }
                .frame(height: 8)

                Text(footer)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(isOverBudget ? .red : .secondary)
            }
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct LockedBudgetPreviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.orange)
                    .frame(width: 24, height: 24)
                    .background(Color.orange.opacity(0.12), in: Circle())

                Text("Suivi du budget avec Premium")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tertiary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.yellow, Color.orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * 0.62)
                        .opacity(0.55)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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
