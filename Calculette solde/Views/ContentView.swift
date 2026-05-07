import SwiftUI

struct ContentView: View {
    @StateObject private var productStore: ProductStore
    @StateObject private var viewModel: MainCalculatorViewModel
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @FocusState var focusedField: Field?

    init() {
        let productStore = ProductStore()
        _productStore = StateObject(wrappedValue: productStore)
        _viewModel = StateObject(wrappedValue: MainCalculatorViewModel(productStore: productStore))
    }

    enum Field: Hashable {
        case price
        case productName
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
                    if let errorMessage = viewModel.errorMessage, !viewModel.isOverBudget {
                        ErrorMessageView(message: errorMessage)
                            .padding(.top, 16)
                    }
                    ResultSectionView(viewModel: viewModel)
                        .padding(.top, 24)
                    ActionButtonsView(viewModel: viewModel, focusedField: $focusedField)
                        .padding(.top, 24)
                    ScannedBarcodeView(viewModel: viewModel)
                        .padding(.top, 16)
                    AddedProductsListView(
                        viewModel: viewModel,
                        productStore: productStore
                    )
                        .padding(.top, 24)
                    if !viewModel.savedProducts.isEmpty {
                        AdMobBannerView()
                            .padding(.top, 12)
                            .padding(.horizontal)
                    }
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
                VStack(spacing: 8) {
                    if viewModel.savedProducts.isEmpty {
                        AdMobBannerView()
                            .padding(.horizontal)
                    }

                    if viewModel.finalPrice != nil {
                        SaveBarView(
                            viewModel: viewModel,
                            onProductAdded: interstitialAdManager.recordAddedProduct
                        )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.finalPrice)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isOverBudget)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.errorMessage)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.savedProducts)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.scannedBarcode)
        }
        .onTapGesture { focusedField = nil }
        .task {
            interstitialAdManager.loadAdIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}
