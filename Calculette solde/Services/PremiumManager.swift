import Foundation
import StoreKit

@MainActor
final class PremiumManager: ObservableObject {
    static let removeAdsProductID = "sf_premium_pack_1.99"

    @Published private(set) var isPremiumActive: Bool
    @Published private(set) var isLoading = false
    @Published private(set) var products: [StoreKit.Product] = []
    @Published var errorMessage: String?
    @Published var statusMessage: String?

    private let productIDs: Set<String>
    private let cacheKey = "com.slideofdigital.Calculette-solde.removeAdsPremiumCache"
    private var transactionUpdatesTask: Task<Void, Never>?
    private var purchaseIntentsTask: Task<Void, Never>?

    init(productIDs: Set<String> = [PremiumManager.removeAdsProductID]) {
        self.productIDs = productIDs
        self.isPremiumActive = UserDefaults.standard.bool(forKey: cacheKey)

        transactionUpdatesTask = observeTransactionUpdates()
        purchaseIntentsTask = observePurchaseIntents()

        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
        purchaseIntentsTask?.cancel()
    }

    var removeAdsProduct: StoreKit.Product? {
        products.first { $0.id == Self.removeAdsProductID }
    }

    var displayName: String {
        removeAdsProduct?.displayName ?? "Supprimer les pubs"
    }

    var description: String {
        removeAdsProduct?.description ?? "Retirez les bannières et publicités interstitielles de Solde facile."
    }

    var displayPrice: String {
        removeAdsProduct?.displayPrice ?? "Prix indisponible"
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedProducts = try await StoreKit.Product.products(for: Array(productIDs))
            products = fetchedProducts.sorted { $0.id < $1.id }

            if removeAdsProduct == nil {
                statusMessage = nil
                errorMessage = "Offre indisponible pour le moment. Vérifiez la configuration StoreKit locale ou App Store Connect."
            } else {
                statusMessage = "Offre disponible."
            }
        } catch {
            products = []
            statusMessage = nil
            errorMessage = "Impossible de charger l’offre : \(error.localizedDescription)"
        }

        isLoading = false
    }

    func reloadProducts() {
        Task { await loadProducts() }
    }

    func purchaseRemoveAds() {
        Task { await purchase(product: removeAdsProduct) }
    }

    func restorePurchases() {
        Task {
            isLoading = true
            errorMessage = nil
            statusMessage = "Restauration en cours..."

            do {
                try await AppStore.sync()
                await refreshEntitlements()
                statusMessage = isPremiumActive ? "Achat restauré." : nil
                errorMessage = isPremiumActive ? nil : "Aucun achat à restaurer."
            } catch {
                statusMessage = nil
                errorMessage = "Restauration impossible : \(error.localizedDescription)"
            }

            isLoading = false
        }
    }

    private func purchase(product optionalProduct: StoreKit.Product?) async {
        guard let product = optionalProduct else {
            errorMessage = "Produit non disponible."
            return
        }

        guard productIDs.contains(product.id) else {
            errorMessage = "Produit non reconnu."
            return
        }

        isLoading = true
        errorMessage = nil
        statusMessage = "Achat en cours..."

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await complete(transaction: transaction, statusMessage: "Achat activé.")
            case .userCancelled:
                statusMessage = "Achat annulé."
            case .pending:
                statusMessage = nil
                errorMessage = "Achat en attente d’approbation."
            @unknown default:
                statusMessage = nil
                errorMessage = "État d’achat inconnu."
            }
        } catch {
            statusMessage = nil
            errorMessage = "Achat impossible : \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }

                do {
                    let transaction = try Self.checkVerified(update)
                    await self.complete(transaction: transaction, statusMessage: "Achat activé.")
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Transaction non vérifiée."
                    }
                }
            }
        }
    }

    private func observePurchaseIntents() -> Task<Void, Never> {
        Task { [weak self] in
            for await purchaseIntent in PurchaseIntent.intents {
                guard let self else { return }
                await self.purchase(product: purchaseIntent.product)
            }
        }
    }

    private func refreshEntitlements() async {
        var hasPremiumEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? Self.checkVerified(result) else { continue }

            if productIDs.contains(transaction.productID) {
                hasPremiumEntitlement = true
                break
            }
        }

        setPremiumActive(hasPremiumEntitlement)
    }

    private func complete(transaction: Transaction, statusMessage: String) async {
        guard productIDs.contains(transaction.productID) else {
            await transaction.finish()
            return
        }

        setPremiumActive(true)
        errorMessage = nil
        self.statusMessage = statusMessage
        await transaction.finish()
    }

    private func setPremiumActive(_ isActive: Bool) {
        isPremiumActive = isActive
        UserDefaults.standard.set(isActive, forKey: cacheKey)
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
}
