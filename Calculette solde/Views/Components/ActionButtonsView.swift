import AVFoundation
import SwiftUI
import UIKit

struct ActionButtonsView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    @ObservedObject var viewModel: MainCalculatorViewModel
    @FocusState.Binding var focusedField: ContentView.Field?
    @StateObject private var scanAccessManager = ScanAccessManager()
    @StateObject private var rewardedAdManager = RewardedAdManager()
    @State private var isScannerPresented = false
    @State private var isScanLimitSheetPresented = false
    @State private var isCameraAccessAlertPresented = false

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
        .sheet(isPresented: $isScanLimitSheetPresented) {
            ScanLimitSheetView(
                premiumManager: premiumManager,
                rewardedAdManager: rewardedAdManager,
                onWatchAd: unlockScanWithRewardedAd
            )
            .onAppear {
                rewardedAdManager.loadAdIfNeeded()
            }
        }
        .alert("Accès caméra nécessaire", isPresented: $isCameraAccessAlertPresented) {
            Button("Annuler", role: .cancel) {}
            Button("Ouvrir Réglages") {
                openAppSettings()
            }
        } message: {
            Text("Autorisez l’accès à la caméra dans les réglages de l’iPhone pour scanner un code-barres.")
        }
        .onChange(of: premiumManager.isPremiumActive) { _, isPremiumActive in
            guard isPremiumActive, isScanLimitSheetPresented else { return }
            isScanLimitSheetPresented = false
            requestCameraAccessThenStartScan()
        }
    }

    private var scanButton: some View {
        Button {
            requestScan()
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

    private func requestScan() {
        focusedField = nil

        guard scanAccessManager.canStartScan(isPremiumActive: premiumManager.isPremiumActive) else {
            isScanLimitSheetPresented = true
            rewardedAdManager.loadAdIfNeeded()
            return
        }

        requestCameraAccessThenStartScan()
    }

    private func requestCameraAccessThenStartScan() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startScan()

        case .notDetermined:
            Task {
                let isGranted = await AVCaptureDevice.requestAccess(for: .video)
                if isGranted {
                    startScan()
                } else {
                    isCameraAccessAlertPresented = true
                }
            }

        case .denied, .restricted:
            isCameraAccessAlertPresented = true

        @unknown default:
            isCameraAccessAlertPresented = true
        }
    }

    private func startScan() {
        scanAccessManager.recordScanStart(isPremiumActive: premiumManager.isPremiumActive)
        isScannerPresented = true
    }

    private func unlockScanWithRewardedAd() {
        rewardedAdManager.presentAd {
            scanAccessManager.grantRewardedScan()
            isScanLimitSheetPresented = false
            requestCameraAccessThenStartScan()
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
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
    .environmentObject(PremiumManager())
}
