import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel
    @FocusState.Binding var focusedField: ContentView.Field?
    @State private var isScannerPresented = false

    var body: some View {
        HStack(spacing: 12) {
            scanButton
            resetButton
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $isScannerPresented) {
            BarcodeScannerView { barcode in
                viewModel.handleScannedBarcode(barcode)
            }
        }
    }

    private var scanButton: some View {
        Button {
            focusedField = nil
            isScannerPresented = true
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
}

#Preview {
    @Previewable @FocusState var focusedField: ContentView.Field?
    ActionButtonsView(
        viewModel: MainCalculatorViewModel(),
        focusedField: $focusedField
    )
}
