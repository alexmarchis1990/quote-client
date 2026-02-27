import NaturalLanguage
import SwiftUI
import UIKit

struct ScanResultView: View {
    let text: String
    let onTryAgain: () -> Void
    @State private var editableText: String = ""
    @State private var detectedLanguageLabel: String?
    @State private var bookSearchQuery: String = ""
    @State private var bookSuggestions: [OpenLibraryBook] = []
    @State private var isSearchingBooks: Bool = false
    @State private var selectedBook: OpenLibraryBook?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let detectedLanguageLabel {
                    Text("Detected language: \(detectedLanguageLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                TextEditor(text: $editableText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(height: 160)

                HStack(spacing: 16) {
                    Button {
                        UIPasteboard.general.string = editableText
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .cancel, action: onTryAgain) {
                        Label("Try again", systemImage: "camera")
                    }
                    .buttonStyle(.bordered)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Book")
                        .font(.headline)
                    TextField("Book name or author", text: $bookSearchQuery)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .onChange(of: bookSearchQuery) { _, newValue in
                            runDebouncedBookSearch(query: newValue)
                        }
                    if isSearchingBooks {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let selectedBook {
                        HStack {
                            Text("\(selectedBook.title)\(selectedBook.authorName.isEmpty ? "" : " — \(selectedBook.authorName)")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Spacer()
                            Button("Clear", role: .cancel) {
                                self.selectedBook = nil
                            }
                            .font(.caption)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    if !bookSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(bookSuggestions) { book in
                                Button {
                                    selectedBook = book
                                    bookSuggestions = []
                                    bookSearchQuery = ""
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(book.title)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        if !book.authorName.isEmpty {
                                            Text(book.authorName)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                        .frame(maxHeight: 200)
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Recognized text")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editableText = text
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            detectedLanguageLabel = recognizer.dominantLanguage.map { Locale.current.localizedString(forLanguageCode: $0.rawValue) ?? $0.rawValue }
        }
    }

    private func runDebouncedBookSearch(query: String) {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            bookSuggestions = []
            isSearchingBooks = false
            return
        }
        let task = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await MainActor.run { isSearchingBooks = true }
            defer { Task { @MainActor in isSearchingBooks = false } }
            do {
                let results = try await OpenLibraryService.searchBooks(query: query, limit: 10)
                guard !Task.isCancelled else { return }
                await MainActor.run { bookSuggestions = results }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { bookSuggestions = [] }
            }
        }
        searchTask = task
    }
}

#Preview {
    NavigationStack {
        ScanResultView(
            text: "It was the best of times, it was the worst of times.",
            onTryAgain: {}
        )
    }
}
