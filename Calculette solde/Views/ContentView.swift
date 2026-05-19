import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @StateObject private var productStore: ProductStore
    @StateObject private var categoryStore: CategoryStore
    @StateObject private var settingsStore: SettingsStore
    @StateObject private var viewModel: MainCalculatorViewModel
    @StateObject private var interstitialAdManager = InterstitialAdManager()
    @State private var isPremiumSheetPresented = false
    @State private var isSettingsSheetPresented = false
    @State private var premiumContext: PremiumPresentationContext = .general
    @FocusState var focusedField: Field?

    init() {
        let productStore = ProductStore()
        let categoryStore = CategoryStore()
        let settingsStore = SettingsStore(persistsSettings: true)
        _productStore = StateObject(wrappedValue: productStore)
        _categoryStore = StateObject(wrappedValue: categoryStore)
        _settingsStore = StateObject(wrappedValue: settingsStore)
        _viewModel = StateObject(wrappedValue: MainCalculatorViewModel(
            categoryStore: categoryStore,
            productStore: productStore,
            settingsStore: settingsStore
        ))
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
                    if let errorMessage = viewModel.errorMessage {
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
                        productStore: productStore,
                        onBudgetSettingsTap: presentBudgetSettings
                    )
                        .padding(.top, 24)
                    if !premiumManager.isPremiumActive, !viewModel.savedProducts.isEmpty {
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
            .navigationTitle("Solde Facile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        presentBudgetSettings()
                    } label: {
                        Label("Réglages", systemImage: "gearshape")
                    }

                    Button {
                        presentPremium(.general)
                    } label: {
                        Label("Premium", systemImage: premiumManager.isPremiumActive ? "crown.fill" : "crown")
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("OK") { focusedField = nil }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    if !premiumManager.isPremiumActive, viewModel.savedProducts.isEmpty {
                        AdMobBannerView()
                            .padding(.horizontal)
                    }

                    if viewModel.finalPrice != nil {
                        SaveBarView(
                            viewModel: viewModel,
                            onProductAdded: recordAddedProductIfNeeded
                        )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.finalPrice)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.errorMessage)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.savedProducts)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.scannedBarcode)
        }
        .onTapGesture { focusedField = nil }
        .sheet(isPresented: $isPremiumSheetPresented) {
            PremiumUpgradeView(
                premiumManager: premiumManager,
                context: premiumContext
            )
        }
        .sheet(isPresented: $isSettingsSheetPresented) {
            BudgetSettingsView(settingsStore: settingsStore)
        }
        .task {
            if !premiumManager.isPremiumActive {
                interstitialAdManager.loadAdIfNeeded()
            }
        }
        .onChange(of: premiumManager.isPremiumActive) { _, isPremiumActive in
            if !isPremiumActive {
                interstitialAdManager.loadAdIfNeeded()
            }
        }
    }


    private func presentPremium(_ context: PremiumPresentationContext) {
        premiumContext = context
        isPremiumSheetPresented = true
    }

    private func presentBudgetSettings() {
        guard premiumManager.isPremiumActive else {
            presentPremium(.budget)
            return
        }

        isSettingsSheetPresented = true
    }

    private func recordAddedProductIfNeeded() {
        guard !premiumManager.isPremiumActive else { return }
        interstitialAdManager.recordAddedProduct()
    }
}

#Preview {
    ContentView()
        .environmentObject(PremiumManager())
}
