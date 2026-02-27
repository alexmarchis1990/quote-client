import NaturalLanguage
import SwiftUI
import UIKit

private let resultContentSpacing: CGFloat = 20
private let resultBottomPadding: CGFloat = 80
private let resultNavigationTitle = "Recognized text"
private let resultDetectedLanguagePrefix = "Detected language: "
private let resultCopyLabel = "Copy"
private let resultTryAgainLabel = "Try again"
private let resultActionSpacing: CGFloat = 16

struct ScanResultView: View {
    let text: String
    let onTryAgain: () -> Void

    @State private var editableText = ""
    @State private var detectedLanguageLabel: String?
    @State private var selectedBook: OpenLibraryBook?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: resultContentSpacing) {
                if let detectedLanguageLabel {
                    DetectedLanguageBanner(label: "\(resultDetectedLanguagePrefix)\(detectedLanguageLabel)")
                }

                QuoteTextEditorSection(
                    text: $editableText,
                    onCopy: { UIPasteboard.general.string = editableText },
                    onTryAgain: onTryAgain
                )

                BookSearchView(selectedBook: $selectedBook)
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
            detectedLanguageLabel = recognizer.dominantLanguage.map {
                Locale.current.localizedString(forLanguageCode: $0.rawValue) ?? $0.rawValue
            }
        }
    }
}

// MARK: - Subviews

private struct DetectedLanguageBanner: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private let resultTextEditorHeight: CGFloat = 160

private struct QuoteTextEditorSection: View {
    @Binding var text: String
    let onCopy: () -> Void
    let onTryAgain: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $text)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(height: resultTextEditorHeight)
                .accessibilityLabel("Recognized text")

            HStack(spacing: resultActionSpacing) {
                Button(action: onCopy) {
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
        }
    }
}

private let resultBookSectionSpacing: CGFloat = 8
private let resultBookSectionTitle = "Book"
private let resultBookSearchPlaceholder = "Book name or author"
private let resultSearchingLabel = "Searching…"
private let resultClearLabel = "Clear"
private let resultSelectedBookPadding: CGFloat = 8
private let resultSelectedBookCornerRadius: CGFloat = 8
private let resultSuggestionsTopPadding: CGFloat = 8
private let resultSuggestionsMaxHeight: CGFloat = 200

private struct BookSearchView: View {
    @Binding var selectedBook: OpenLibraryBook?

    @State private var bookSearchQuery = ""
    @State private var bookSuggestions: [OpenLibraryBook] = []
    @State private var isSearchingBooks = false

    var body: some View {
        VStack(alignment: .leading, spacing: resultBookSectionSpacing) {
            Text(resultBookSectionTitle)
                .font(.headline)

            TextField(resultBookSearchPlaceholder, text: $bookSearchQuery)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

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
                SelectedBookChip(book: selectedBook) {
                    self.selectedBook = nil
                }
            }

            if !bookSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bookSuggestions) { book in
                        BookSuggestionRow(book: book) {
                            selectedBook = book
                            bookSuggestions = []
                            bookSearchQuery = ""
                        }
                    }
                }
                .padding(.top, resultSuggestionsTopPadding)
                .frame(maxHeight: resultSuggestionsMaxHeight)
            }
        }
        .task(id: bookSearchQuery) {
            let trimmed = bookSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                bookSuggestions = []
                isSearchingBooks = false
                return
            }
            do {
                try await Task.sleep(for: .milliseconds(300))
            } catch {
                return
            }
            isSearchingBooks = true
            defer { isSearchingBooks = false }
            do {
                bookSuggestions = try await OpenLibraryService.searchBooks(query: trimmed, limit: 10)
            } catch {
                if !Task.isCancelled { bookSuggestions = [] }
            }
        }
    }
}

private struct SelectedBookChip: View {
    let book: OpenLibraryBook
    let onClear: () -> Void

    var body: some View {
        HStack {
            Text(book.authorName.isEmpty ? book.title : "\(book.title) — \(book.authorName)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            Spacer()
            Button(resultClearLabel, role: .cancel, action: onClear)
                .font(.caption)
        }
        .padding(resultSelectedBookPadding)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: resultSelectedBookCornerRadius))
    }
}

private struct BookSuggestionRow: View {
    let book: OpenLibraryBook
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
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

#Preview {
    NavigationStack {
        ScanResultView(
            text: "It was the best of times, it was the worst of times.",
            onTryAgain: {}
        )
    }
}
