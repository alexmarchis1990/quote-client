import SwiftUI

private let signUpStackSpacing: CGFloat = 24
private let signUpFieldSpacing: CGFloat = 16
private let signUpFieldCornerRadius: CGFloat = 10
private let signUpHorizontalPadding: CGFloat = 32
private let signUpTitle = "Create Account"
private let usernamePlaceholder = "Username"
private let emailPlaceholder = "Email"
private let passwordPlaceholder = "Password"
private let signUpButtonTitle = "Sign Up"
private let signUpNavigationTitle = "Sign Up"
private let minPasswordLength = 6
private let minUsernameLength = 2

struct SignUpView: View {
    @Bindable var authStore: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""

    private var usernameValidationError: String? {
        guard !username.isEmpty else { return nil }
        return username.count >= minUsernameLength ? nil : "Username must be at least \(minUsernameLength) characters"
    }

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
        !username.isEmpty && !email.isEmpty && !password.isEmpty
            && usernameValidationError == nil
            && emailValidationError == nil
            && passwordValidationError == nil
    }

    var body: some View {
        VStack(spacing: signUpStackSpacing) {
            Spacer()

            Text(signUpTitle)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: signUpFieldSpacing) {
                validatedField {
                    TextField(usernamePlaceholder, text: $username)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } error: { usernameValidationError }

                validatedField {
                    TextField(emailPlaceholder, text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } error: { emailValidationError }

                validatedField {
                    SecureField(passwordPlaceholder, text: $password)
                        .textContentType(.newPassword)
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
                    await authStore.signup(email: email, password: password, username: username)
                }
            } label: {
                Group {
                    if authStore.loadingState == .loading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(signUpButtonTitle)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!isFormValid || authStore.loadingState == .loading)
            .accessibilityLabel(signUpButtonTitle)

            Spacer()
        }
        .padding(.horizontal, signUpHorizontalPadding)
        .navigationTitle(signUpNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
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
                .clipShape(RoundedRectangle(cornerRadius: signUpFieldCornerRadius))

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
        SignUpView(authStore: AuthStore(service: .mock))
    }
}
