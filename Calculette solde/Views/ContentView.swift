import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainCalculatorViewModel()
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case productName
        case originalPrice
        case customDiscount
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    productNameField
                    priceField
                    discountRateSelector
                    customDiscountField
                    resultSection
                    budgetWarning
                    actionButtons
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color(.systemGroupedBackground))
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

    // MARK: - Title

    private var titleSection: some View {
        VStack(spacing: 4) {
            Text("Calculez le prix après remise")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: - Product Name

    private var productNameField: some View {
        LabeledContent {
            TextField("Ex: Pull en laine", text: $viewModel.productName)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: .productName)
                .submitLabel(.next)
                .onSubmit { focusedField = .originalPrice }
        } label: {
            Label("Nom du produit", systemImage: "tag")
                .font(.subheadline)
        }
    }

    // MARK: - Price

    private var priceField: some View {
        LabeledContent {
            HStack(spacing: 0) {
                TextField("0,00", text: $viewModel.originalPriceText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .originalPrice)
                    .onChange(of: viewModel.originalPriceText) { _ in
                        viewModel.calculate()
                    }
                Text("€")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
        } label: {
            Label("Prix initial", systemImage: "eurosign")
                .font(.subheadline)
        }
    }

    // MARK: - Discount Rate Selector

    private var discountRateSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Taux de remise", systemImage: "percent")
                .font(.subheadline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableDiscountRates) { rate in
                        Button {
                            viewModel.selectDiscountRate(rate)
                            viewModel.calculate()
                        } label: {
                            Text(rate.label)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    viewModel.selectedDiscountRate == rate
                                        ? Color.accentColor
                                        : Color(.secondarySystemBackground)
                                )
                                .foregroundStyle(
                                    viewModel.selectedDiscountRate == rate
                                        ? .white
                                        : .primary
                                )
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollClipDisabled()
        }
    }

    // MARK: - Custom Discount

    private var customDiscountField: some View {
        LabeledContent {
            HStack(spacing: 0) {
                TextField("Ex: 33", text: $viewModel.customDiscountText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .customDiscount)
                    .onChange(of: viewModel.customDiscountText) { _ in
                        if !viewModel.customDiscountText.isEmpty {
                            viewModel.clearDiscountSelection()
                        }
                        viewModel.calculate()
                    }
                Text("%")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
            }
        } label: {
            Label("Remise personnalisée", systemImage: "slider.horizontal.3")
                .font(.subheadline)
        }
    }

    // MARK: - Result

    @ViewBuilder
    private var resultSection: some View {
        if let finalPrice = viewModel.finalPrice {
            GroupBox {
                VStack(spacing: 16) {
                    resultRow(
                        label: "Remise",
                        amount: viewModel.formattedDiscountAmount,
                        color: .green
                    )

                    Divider()

                    resultRow(
                        label: "Prix final",
                        amount: viewModel.formattedFinalPrice,
                        color: .primary,
                        large: true
                    )
                }
                .padding(.vertical, 4)
            }
            .groupBoxStyle(.automatic)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func resultRow(
        label: String,
        amount: String,
        color: Color,
        large: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(large ? .title3.weight(.medium) : .body)
                .foregroundStyle(.secondary)
            Spacer()
            Text(amount)
                .font(large ? .title2.weight(.bold) : .title3.weight(.semibold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
    }

    // MARK: - Budget Warning

    @ViewBuilder
    private var budgetWarning: some View {
        if viewModel.isOverBudget {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("Le prix final dépasse le budget maximum.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                Spacer()
            }
            .padding(12)
            .background(.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                scanButton
                saveButton
            }

            resetButton
        }
    }

    private var scanButton: some View {
        Button {
            // Future: intégration scan code-barres
        } label: {
            Label("Scanner", systemImage: "barcode.viewfinder")
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var saveButton: some View {
        Button {
            withAnimation {
                viewModel.saveCurrentProduct()
            }
        } label: {
            Label("Enregistrer", systemImage: "square.and.arrow.down")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(viewModel.finalPrice != nil ? Color.accentColor : Color(.tertiarySystemBackground))
                .foregroundStyle(viewModel.finalPrice != nil ? .white : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.finalPrice == nil)
        .buttonStyle(.plain)
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            withAnimation {
                focusedField = nil
                viewModel.reset()
            }
        } label: {
            Label("Réinitialiser", systemImage: "arrow.counterclockwise")
                .font(.subheadline)
        }
        .buttonStyle(.borderless)
        .tint(.secondary)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
