import SwiftUI

private let discountGradient = LinearGradient(
    colors: [Color.orange, Color.pink],
    startPoint: .leading,
    endPoint: .trailing
)

struct DiscountSectionView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel
    @FocusState.Binding var focusedField: ContentView.Field?

    var body: some View {
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
}

#Preview {
    @Previewable @FocusState var focusedField: ContentView.Field?
    DiscountSectionView(
        viewModel: MainCalculatorViewModel(),
        focusedField: $focusedField
    )
}
