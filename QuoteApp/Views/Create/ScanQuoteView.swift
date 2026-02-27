import SwiftUI

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
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Reading text…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 24) {
                        Text("Add from photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 16) {
                            Button {
                                showingCamera = true
                            } label: {
                                Label("Take photo", systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)

                            Button {
                                showingLibrary = true
                            } label: {
                                Label("Choose from library", systemImage: "photo.on.rectangle.angled")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                        }
                        .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Scan quote")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { text in
                ScanResultView(text: text) {
                    scanPath = []
                }
            }
            .alert("Error", isPresented: .init(
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
                    onCancel: {
                        showingCamera = false
                    }
                )
            }
            .fullScreenCover(isPresented: $showingLibrary) {
                ImagePicker(
                    sourceType: .photoLibrary,
                    onImagePicked: { image in
                        showingLibrary = false
                        recognizeText(from: image)
                    },
                    onCancel: {
                        showingLibrary = false
                    }
                )
            }
        }
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
                        errorMessage = "No text was found in the image."
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
