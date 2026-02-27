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

struct LoginView: View {
    @Bindable var authStore: AuthStore
    @State private var email = "user@example.com"
    @State private var password = "password123"

    var body: some View {
        VStack(spacing: loginStackSpacing) {
            Spacer()

            Text(appTitle)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: loginFieldSpacing) {
                TextField(emailPlaceholder, text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: loginFieldCornerRadius))

                SecureField(passwordPlaceholder, text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: loginFieldCornerRadius))
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
            .disabled(email.isEmpty || password.isEmpty || authStore.loadingState == .loading)
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
}

#Preview {
    NavigationStack {
        LoginView(authStore: AuthStore(service: .mock))
    }
}
