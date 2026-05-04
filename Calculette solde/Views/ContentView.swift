import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainCalculatorViewModel()
    @FocusState var focusedField: Field?

    enum Field: Hashable {
        case price
        case customDiscount
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HeroHeaderView()
                    PriceSectionView(viewModel: viewModel, focusedField: $focusedField)
                        .padding(.top, 20)
                    DiscountSectionView(viewModel: viewModel, focusedField: $focusedField)
                        .padding(.top, 24)
                    ResultSectionView(viewModel: viewModel)
                        .padding(.top, 24)
                    ActionButtonsView(viewModel: viewModel, focusedField: $focusedField)
                        .padding(.top, 24)
                    Spacer(minLength: 40)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .background {
                Color(.systemGroupedBackground)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
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
            .safeAreaInset(edge: .bottom) {
                if viewModel.finalPrice != nil {
                    SaveBarView(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.finalPrice)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isOverBudget)
        }
        .onTapGesture { focusedField = nil }
    }
}

#Preview {
    ContentView()
}
