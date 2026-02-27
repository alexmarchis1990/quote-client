import SwiftUI

private let scanRecognizingSpacing: CGFloat = 16
private let scanMainSpacing: CGFloat = 24
private let scanButtonSpacing: CGFloat = 16
private let scanHorizontalPadding: CGFloat = 32
private let scanNavigationTitle = "Scan quote"
private let scanReadingTextLabel = "Reading text…"
private let scanAddFromPhotoLabel = "Add from photo"
private let scanTakePhotoLabel = "Take photo"
private let scanChooseLibraryLabel = "Choose from library"
private let scanErrorAlertTitle = "Error"
private let scanNoTextMessage = "No text was found in the image."

struct ScanQuoteView: View {
    @State private var scanPath: [String] = []
    @State private var showingCamera = false
    @State private var showingLibrary = false
    @State private var isRecognizing = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack(path: $scanPath) {
            Group {
                if isRecognizing {
                    recognizingOverlay
                } else {
                    scanSourceButtons
                }
            }
            .navigationTitle(scanNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { text in
                ScanResultView(text: text) {
                    scanPath = []
                }
            }
            .alert(scanErrorAlertTitle, isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil; isRecognizing = false } }
            )) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                    isRecognizing = false
                }
            } message: {
                Text(errorMessage ?? "")
            }
            .fullScreenCover(isPresented: $showingCamera) {
                ImagePicker(
                    sourceType: .camera,
                    onImagePicked: { image in
                        showingCamera = false
                        recognizeText(from: image)
                    },
                    onCancel: { showingCamera = false }
                )
            }
            .fullScreenCover(isPresented: $showingLibrary) {
                ImagePicker(
                    sourceType: .photoLibrary,
                    onImagePicked: { image in
                        showingLibrary = false
                        recognizeText(from: image)
                    },
                    onCancel: { showingLibrary = false }
                )
            }
        }
    }

    private var recognizingOverlay: some View {
        VStack(spacing: scanRecognizingSpacing) {
            ProgressView()
            Text(scanReadingTextLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(scanReadingTextLabel)
    }

    private var scanSourceButtons: some View {
        VStack(spacing: scanMainSpacing) {
            Text(scanAddFromPhotoLabel)
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(spacing: scanButtonSpacing) {
                Button {
                    showingCamera = true
                } label: {
                    Label(scanTakePhotoLabel, systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(scanTakePhotoLabel)

                Button {
                    showingLibrary = true
                } label: {
                    Label(scanChooseLibraryLabel, systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityLabel(scanChooseLibraryLabel)
            }
            .padding(.horizontal, scanHorizontalPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func recognizeText(from image: UIImage) {
        isRecognizing = true
        errorMessage = nil
        Task {
            do {
                let text = try await TextRecognitionService.recognizeText(from: image)
                await MainActor.run {
                    isRecognizing = false
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = scanNoTextMessage
                    } else {
                        scanPath = [text]
                    }
                }
            } catch {
                await MainActor.run {
                    isRecognizing = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ScanQuoteView()
}
