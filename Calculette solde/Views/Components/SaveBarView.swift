import SwiftUI

private let accentGradient = LinearGradient(
    colors: [Color.blue, Color.purple],
    startPoint: .leading,
    endPoint: .trailing
)

struct SaveBarView: View {
    @ObservedObject var viewModel: MainCalculatorViewModel

    var body: some View {
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

#Preview {
    SaveBarView(viewModel: MainCalculatorViewModel())
}
