import NaturalLanguage
import SwiftUI
import UIKit

private let resultContentSpacing: CGFloat = 20
private let resultTextEditorHeight: CGFloat = 160
private let resultActionSpacing: CGFloat = 16
private let resultBookSectionSpacing: CGFloat = 8
private let resultSelectedBookPadding: CGFloat = 8
private let resultSelectedBookCornerRadius: CGFloat = 8
private let resultSuggestionsTopPadding: CGFloat = 8
private let resultSuggestionsMaxHeight: CGFloat = 200
private let resultBottomPadding: CGFloat = 80
private let resultNavigationTitle = "Recognized text"
private let resultDetectedLanguagePrefix = "Detected language: "
private let resultCopyLabel = "Copy"
private let resultTryAgainLabel = "Try again"
private let resultBookSectionTitle = "Book"
private let resultBookSearchPlaceholder = "Book name or author"
private let resultSearchingLabel = "Searching…"
private let resultClearLabel = "Clear"

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
            VStack(alignment: .leading, spacing: resultContentSpacing) {
                if let detectedLanguageLabel {
                    Text("\(resultDetectedLanguagePrefix)\(detectedLanguageLabel)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                TextEditor(text: $editableText)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .frame(height: resultTextEditorHeight)
                    .accessibilityLabel("Recognized text")

                HStack(spacing: resultActionSpacing) {
                    Button {
                        UIPasteboard.general.string = editableText
                    } label: {
                        Label(resultCopyLabel, systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel(resultCopyLabel)

                    Button(role: .cancel, action: onTryAgain) {
                        Label(resultTryAgainLabel, systemImage: "camera")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel(resultTryAgainLabel)
                }

                bookSearchSection
            }
            .padding()
            .padding(.bottom, resultBottomPadding)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(resultNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editableText = text
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            detectedLanguageLabel = recognizer.dominantLanguage.map { Locale.current.localizedString(forLanguageCode: $0.rawValue) ?? $0.rawValue }
        }
    }

    @ViewBuilder
    private var bookSearchSection: some View {
        VStack(alignment: .leading, spacing: resultBookSectionSpacing) {
            Text(resultBookSectionTitle)
                .font(.headline)

            TextField(resultBookSearchPlaceholder, text: $bookSearchQuery)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .onChange(of: bookSearchQuery) { _, newValue in
                    runDebouncedBookSearch(query: newValue)
                }

            if isSearchingBooks {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text(resultSearchingLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(resultSearchingLabel)
            }

            if let selectedBook {
                HStack {
                    Text(selectedBook.authorName.isEmpty
                        ? selectedBook.title
                        : "\(selectedBook.title) — \(selectedBook.authorName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                    Button(resultClearLabel, role: .cancel) {
                        self.selectedBook = nil
                    }
                    .font(.caption)
                }
                .padding(resultSelectedBookPadding)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: resultSelectedBookCornerRadius))
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
                .padding(.top, resultSuggestionsTopPadding)
                .frame(maxHeight: resultSuggestionsMaxHeight)
            }
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
