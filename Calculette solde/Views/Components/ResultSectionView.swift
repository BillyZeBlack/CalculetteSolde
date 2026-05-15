import SwiftUI

struct ResultSectionView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel

    var body: some View {
        if let _ = viewModel.finalPrice {
            VStack(spacing: 0) {
                discountAmountRow
                Divider()
                    .padding(.leading)
                finalPriceRow
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

}

#Preview {
    ResultSectionView(viewModel: MainCalculatorViewModel())
}
