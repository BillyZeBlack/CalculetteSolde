import SwiftUI

private let accentGradient = LinearGradient(
    colors: [Color.blue, Color.purple],
    startPoint: .leading,
    endPoint: .trailing
)

struct PriceSectionView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel
    @FocusState.Binding var focusedField: ContentView.Field?

    var body: some View {
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
}

#Preview {
    @Previewable @FocusState var focusedField: ContentView.Field?
    PriceSectionView(
        viewModel: MainCalculatorViewModel(),
        focusedField: $focusedField
    )
}
