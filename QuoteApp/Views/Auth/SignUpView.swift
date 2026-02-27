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

struct SignUpView: View {
    @Bindable var authStore: AuthStore
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""

    var body: some View {
        VStack(spacing: signUpStackSpacing) {
            Spacer()

            Text(signUpTitle)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: signUpFieldSpacing) {
                TextField(usernamePlaceholder, text: $username)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: signUpFieldCornerRadius))

                TextField(emailPlaceholder, text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: signUpFieldCornerRadius))

                SecureField(passwordPlaceholder, text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: signUpFieldCornerRadius))
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
            .disabled(email.isEmpty || password.isEmpty || username.isEmpty || authStore.loadingState == .loading)
            .accessibilityLabel(signUpButtonTitle)

            Spacer()
        }
        .padding(.horizontal, signUpHorizontalPadding)
        .navigationTitle(signUpNavigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUpView(authStore: AuthStore(service: .mock))
    }
}
