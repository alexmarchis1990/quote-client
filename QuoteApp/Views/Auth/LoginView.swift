import SwiftUI

private let loginStackSpacing: CGFloat = 24
private let loginFieldSpacing: CGFloat = 16
private let loginFieldCornerRadius: CGFloat = 10
private let loginHorizontalPadding: CGFloat = 32
private let appTitle = "QuoteApp"
private let emailPlaceholder = "Email"
private let passwordPlaceholder = "Password"
private let logInButtonTitle = "Log In"
private let signUpPrompt = "Don't have an account? Sign Up"
private let minPasswordLength = 6

struct LoginView: View {
    @Bindable var authStore: AuthStore
    @State private var email = "user@example.com"
    @State private var password = "password123"

    private var emailValidationError: String? {
        guard !email.isEmpty else { return nil }
        let parts = email.split(separator: "@", maxSplits: 1)
        guard parts.count == 2, let domain = parts.last, domain.contains(".") else {
            return "Enter a valid email address"
        }
        return nil
    }

    private var passwordValidationError: String? {
        guard !password.isEmpty else { return nil }
        return password.count >= minPasswordLength ? nil : "Password must be at least \(minPasswordLength) characters"
    }

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
            && emailValidationError == nil
            && passwordValidationError == nil
    }

    var body: some View {
        VStack(spacing: loginStackSpacing) {
            Spacer()

            Text(appTitle)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: loginFieldSpacing) {
                validatedField {
                    TextField(emailPlaceholder, text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } error: { emailValidationError }

                validatedField {
                    SecureField(passwordPlaceholder, text: $password)
                        .textContentType(.password)
                } error: { passwordValidationError }
            }

            if case .error(let message) = authStore.loadingState {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .accessibilityLabel("Error: \(message)")
            }

            Button {
                Task {
                    await authStore.login(email: email, password: password)
                }
            } label: {
                Group {
                    if authStore.loadingState == .loading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(logInButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!isFormValid || authStore.loadingState == .loading)
            .accessibilityLabel(logInButtonTitle)

            NavigationLink(value: Screen.auth(.signup)) {
                Text(signUpPrompt)
                    .font(.footnote)
            }
            .accessibilityLabel(signUpPrompt)

            Spacer()
        }
        .padding(.horizontal, loginHorizontalPadding)
    }

    @ViewBuilder
    private func validatedField<Field: View>(
        @ViewBuilder field: () -> Field,
        error: () -> String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            field()
                .padding()
                .background(.fill.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: loginFieldCornerRadius))

            if let message = error() {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .padding(.horizontal, 4)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView(authStore: AuthStore(service: .mock))
    }
}
