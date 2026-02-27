import SwiftUI

struct LoginView: View {
    @Bindable var authStore: AuthStore
    @State private var email = "user@example.com"
    @State private var password = "password123"

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("QuoteApp")
                .font(.largeTitle.bold())

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(.fill.tertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if case .error(let message) = authStore.loadingState {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                Task {
                    await authStore.login(email: email, password: password)
                }
            } label: {
                if authStore.loadingState == .loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.isEmpty || password.isEmpty || authStore.loadingState == .loading)

            NavigationLink(value: Screen.auth(.signup)) {
                Text("Don't have an account? Sign Up")
                    .font(.footnote)
            }

            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    NavigationStack {
        LoginView(authStore: AuthStore(service: .mock))
    }
}
