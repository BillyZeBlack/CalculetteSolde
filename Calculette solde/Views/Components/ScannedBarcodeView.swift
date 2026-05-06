import SwiftUI

struct ScannedBarcodeView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel

    var body: some View {
        if let barcodeValue = viewModel.scannedBarcodeValue {
            HStack(spacing: 12) {
                Image(systemName: "barcode")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("Code-barres scanné")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(barcodeValue)
                        .font(.body.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if let symbology = viewModel.scannedBarcodeSymbologyLabel {
                        Text(symbology)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    lookupState
                }

                Spacer(minLength: 12)

                Button {
                    withAnimation {
                        viewModel.clearScanState()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Effacer le code-barres")
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.blue.opacity(0.16), lineWidth: 1)
            }
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    @ViewBuilder
    private var lookupState: some View {
        if viewModel.isLookingUpScannedProduct {
            HStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.7)
                Text("Recherche du produit")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        } else if let productName = viewModel.productLookupResult?.name {
            Label(productName, systemImage: "checkmark.circle.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(.green)
                .lineLimit(1)
        } else if let errorMessage = viewModel.productLookupErrorMessage {
            Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(.orange)
                .lineLimit(2)
        }
    }
}

#Preview {
    ScannedBarcodeView(
        viewModel: MainCalculatorViewModel(
            scannedBarcode: Barcode(value: "3017620422003", symbology: .ean13)
        )
    )
}
