# QuoteApp

iOS app for quotes, built with SwiftUI. The Xcode project is generated with [Tuist](https://tuist.io).

## Prerequisites

- **Xcode** (compatible with iOS 17)
- **Tuist** — install via Homebrew: `brew install tuist`  
  The project pins Tuist 4.0.0 (see `.tuist-version`). To use that version, run `tuist install` after installing Tuist.

## Clone the repository

```bash
git clone https://github.com/alexmarchis1990/quote-client.git
cd quote-client
```

## Generate the project

From the repository root, run:

```bash
tuist generate
```

This creates `QuoteApp.xcodeproj` and `QuoteApp.xcworkspace`.

## Open and run the app

**Open `QuoteApp.xcodeproj` in Xcode (do not open the `.xcworkspace` file).**

1. Select the **QuoteApp** scheme.
2. Choose a simulator (e.g. iPhone 17) or a connected device.
3. Build and run (⌘R).

## Tips

- **Clean build:** If something looks wrong after pulling changes, use Product → Clean Build Folder (⇧⌘K), then build again.
- **Regenerate:** After pulling changes that touch `Project.swift` or `Tuist.swift`, run `tuist generate` again before opening the project.
