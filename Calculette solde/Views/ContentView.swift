import SwiftUI

// MARK: - Accent Gradient

private let accentGradient = LinearGradient(
    colors: [Color.blue, Color.purple],
    startPoint: .leading,
    endPoint: .trailing
)

private let discountGradient = LinearGradient(
    colors: [Color.orange, Color.pink],
    startPoint: .leading,
    endPoint: .trailing
)

// MARK: - ContentView

struct ContentView: View {
    @StateObject private var viewModel = MainCalculatorViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case price
        case customDiscount
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .background {
                    Color(.systemGroupedBackground)
                        .overlay(alignment: .top) {
                            accentGradient
                                .opacity(0.08)
                                .frame(height: 300)
                                .blur(radius: 60)
                        }
                        .ignoresSafeArea()
                }
                .navigationTitle("Calculette Solde")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("OK") { focusedField = nil }
                    }
                }
                .onTapGesture { focusedField = nil }
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                priceSection
                    .padding(.top, 20)
                discountSection
                    .padding(.top, 24)
                resultSection
                    .padding(.top, 24)
                actionsSection
                    .padding(.top, 24)
                Spacer(minLength: 40)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .safeAreaInset(edge: .bottom) {
            if viewModel.finalPrice != nil {
                saveBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.finalPrice)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isOverBudget)
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 6) {
            Image(systemName: "percent")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(accentGradient)
                .symbolEffect(.bounce, options: .repeating)

            Text("Calculez vos remises")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Saisissez un prix et choisissez une remise")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: - Price Section

    private var priceSection: some View {
        VStack(spacing: 0) {
            priceField
            Divider()
                .padding(.leading)
            productNameField
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accentGradient.opacity(0.15), lineWidth: 1)
        }
        .padding(.horizontal)
    }

    private var priceField: some View {
        HStack {
            Label("Prix initial", systemImage: "eurosign.circle.fill")
                .font(.body.weight(.medium))
                .foregroundStyle(accentGradient)

            Spacer()

            HStack(spacing: 4) {
                TextField("0,00", text: $viewModel.originalPriceText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .frame(maxWidth: 120)
                    .font(.body.weight(.semibold))
                    .onChange(of: viewModel.originalPriceText) { newValue in
                        let filtered = newValue.filter { "0123456789,.".contains($0) }
                        if filtered != newValue {
                            viewModel.originalPriceText = filtered
                        }
                        viewModel.calculate()
                    }
                Text("€")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    private var productNameField: some View {
        HStack {
            Label("Nom", systemImage: "tag.fill")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            TextField("Optionnel", text: $viewModel.productName)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    // MARK: - Discount Section

    private var discountSection: some View {
        VStack(spacing: 0) {
            discountPresets
            Divider()
                .padding(.leading)
            customDiscountField
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(discountGradient.opacity(0.15), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal)
    }

    private var discountPresets: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Taux de remise", systemImage: "percent")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(discountGradient)
                .padding(.horizontal)
                .padding(.top, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableDiscountRates) { rate in
                        Button {
                            viewModel.selectDiscountRate(rate)
                            viewModel.calculate()
                        } label: {
                            Text(rate.label)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background {
                                    if viewModel.selectedDiscountRate == rate {
                                        discountGradient
                                    } else {
                                        Color(.quaternarySystemFill)
                                    }
                                }
                                .foregroundStyle(
                                    viewModel.selectedDiscountRate == rate
                                        ? .white
                                        : .primary
                                )
                                .clipShape(Capsule())
                                .shadow(
                                    color: viewModel.selectedDiscountRate == rate
                                        ? .orange.opacity(0.3)
                                        : .clear,
                                    radius: 6, y: 2
                                )
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(viewModel.selectedDiscountRate == rate ? 1.05 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedDiscountRate)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 14)
            }
        }
    }

    private var customDiscountField: some View {
        HStack {
            Label("Remise personnalisée", systemImage: "slider.horizontal.3")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            HStack(spacing: 4) {
                TextField("%", text: $viewModel.customDiscountText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .customDiscount)
                    .frame(maxWidth: 80)
                    .font(.body.weight(.semibold))
                    .onChange(of: viewModel.customDiscountText) { _ in
                        if !viewModel.customDiscountText.isEmpty {
                            viewModel.clearDiscountSelection()
                        }
                        viewModel.calculate()
                    }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    // MARK: - Result Section

    @ViewBuilder
    private var resultSection: some View {
        if let _ = viewModel.finalPrice {
            VStack(spacing: 0) {
                discountAmountRow
                Divider()
                    .padding(.leading)
                finalPriceRow
                if viewModel.isOverBudget {
                    Divider()
                        .padding(.leading)
                    budgetWarningRow
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            }
            .padding(.horizontal)
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    private var discountAmountRow: some View {
        HStack {
            Label("Remise", systemImage: "arrow.down.to.line.compact")
                .font(.body.weight(.medium))
                .foregroundStyle(.green)

            Spacer()

            Text(viewModel.formattedDiscountAmount)
                .font(.title3.weight(.bold))
                .foregroundStyle(.green)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    private var finalPriceRow: some View {
        HStack {
            Label("Prix final", systemImage: "cart.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Text(viewModel.formattedFinalPrice)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }

    private var budgetWarningRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline)
                .foregroundStyle(.red)

            Text("Budget maximum dépassé")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(.red.opacity(0.06))
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        HStack(spacing: 12) {
            scanButton
            resetButton
        }
        .padding(.horizontal)
    }

    private var scanButton: some View {
        Button {
            // Future: intégration scan code-barres
        } label: {
            Label("Scanner", systemImage: "barcode.viewfinder")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            focusedField = nil
            withAnimation {
                viewModel.reset()
            }
        } label: {
            Label("Réinitialiser", systemImage: "arrow.counterclockwise")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .tint(.red)
    }

    // MARK: - Save Bar

    private var saveBar: some View {
        Button {
            withAnimation {
                viewModel.saveCurrentProduct()
            }
        } label: {
            Label("Enregistrer le produit", systemImage: "square.and.arrow.down")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(accentGradient)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
