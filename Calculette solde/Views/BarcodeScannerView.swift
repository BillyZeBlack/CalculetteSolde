import AVFoundation
import SwiftUI
import UIKit

struct BarcodeScannerView: View {
    let onScan: (Barcode) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var isManualEntryPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                scannerContent

                VStack {
                    Spacer()

                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 260, height: 160)
                        .shadow(radius: 8)

                    Text("Placez le code-barres dans le cadre")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 20)

                    Spacer()
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Saisie") {
                        isManualEntryPresented = true
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.4), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await requestCameraAccessIfNeeded()
            }
            .sheet(isPresented: $isManualEntryPresented) {
                ManualBarcodeEntryView { barcode in
                    onScan(barcode)
                    dismiss()
                }
            }
        }
    }

    @ViewBuilder
    private var scannerContent: some View {
        switch cameraStatus {
        case .authorized:
            BarcodeScannerRepresentable { barcode in
                onScan(barcode)
                dismiss()
            }
            .ignoresSafeArea()

        case .denied, .restricted:
            VStack(spacing: 14) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)

                Text("Accès caméra indisponible")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Autorisez l'accès caméra dans Réglages pour scanner un code-barres.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal)
            }

        case .notDetermined:
            ProgressView()
                .tint(.white)

        @unknown default:
            Text("Scanner indisponible")
                .font(.headline)
                .foregroundStyle(.white)
        }
    }

    private func requestCameraAccessIfNeeded() async {
        guard cameraStatus == .notDetermined else { return }

        let isGranted = await AVCaptureDevice.requestAccess(for: .video)
        cameraStatus = isGranted ? .authorized : .denied
    }
}

private struct ManualBarcodeEntryView: View {
    let onSubmit: (Barcode) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var barcodeValue = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "barcode")
                    .font(.system(size: 48, weight: .semibold))
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Code-barres")
                        .font(.headline)

                    TextField("Saisir le code", text: $barcodeValue)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.title3.monospacedDigit())
                        .padding(14)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.regularMaterial)
                        }
                        .onChange(of: barcodeValue) { _, newValue in
                            barcodeValue = newValue.filter { $0.isNumber }
                            validationMessage = nil
                        }
                }
                .padding(.horizontal)

                if let validationMessage {
                    Text(validationMessage)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    submitBarcode()
                } label: {
                    Label("Utiliser ce code", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(barcodeValue.isEmpty)
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Saisie manuelle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func submitBarcode() {
        let barcode = Barcode(value: barcodeValue)
        guard barcode.isValid else {
            validationMessage = "Le code-barres doit contenir entre 6 et 14 chiffres."
            return
        }

        onSubmit(barcode)
    }
}

private struct BarcodeScannerRepresentable: UIViewControllerRepresentable {
    let onScan: (Barcode) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(onScan: onScan)
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

private final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    private let metadataOutput = AVCaptureMetadataOutput()
    private let onScan: (Barcode) -> Void
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didScan = false

    init(onScan: @escaping (Barcode) -> Void) {
        self.onScan = onScan
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.stopRunning()
        }
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !didScan,
              let metadataObject = metadataObjects.compactMap({ $0 as? AVMetadataMachineReadableCodeObject }).first,
              let value = metadataObject.stringValue
        else {
            return
        }

        let barcode = Barcode(
            value: value,
            symbology: Barcode.Symbology(metadataObjectType: metadataObject.type)
        )

        guard barcode.isValid else { return }

        didScan = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onScan(barcode)
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(metadataOutput)
        else {
            return
        }

        session.addInput(input)
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes.filter {
            supportedObjectTypes.contains($0)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private var supportedObjectTypes: [AVMetadataObject.ObjectType] {
        [
            .ean8,
            .ean13,
            .upce,
            .code39,
            .code39Mod43,
            .code93,
            .code128,
            .itf14,
            .interleaved2of5
        ]
    }
}

private extension Barcode.Symbology {
    init(metadataObjectType: AVMetadataObject.ObjectType) {
        switch metadataObjectType {
        case .ean8:
            self = .ean8
        case .ean13:
            self = .ean13
        case .upce:
            self = .upcE
        case .itf14:
            self = .gtin
        default:
            self = .unknown
        }
    }
}

#Preview {
    BarcodeScannerView(onScan: { _ in })
}
