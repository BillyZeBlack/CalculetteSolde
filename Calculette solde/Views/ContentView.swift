import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainCalculatorViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Calculette solde")
                .font(.title)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.availableDiscountRates) { rate in
                        Text(rate.label)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
