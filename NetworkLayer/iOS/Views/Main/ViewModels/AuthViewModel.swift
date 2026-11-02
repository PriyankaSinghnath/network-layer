import Combine
import Foundation

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var accessToken: String?
    @Published private(set) var username = ""
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?

    private let api: APIManager

    init(api: APIManager) {
        self.api = api
    }

    func authenticate(username: String, email: String, password: String, isSigningUp: Bool) async {
        guard !username.isEmpty, !password.isEmpty, !email.isEmpty || !isSigningUp else {
            errorMessage = "Fill in the required fields to continue."
            return
        }

        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            if isSigningUp {
                let request = SignupRequestModel(email: email, username: username, password: password)
                _ = try await api.signup(requestModel: request)
            }
            let request = LoginRequestModel(username: username, password: password)
            let response = try await api.login(requestModel: request)
            self.username = username
            accessToken = response.token
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() async {
        let request = LogoutRequestModel()
        do {
            try await api.logout(requestModel: request)
        } catch {
            // Always clear the local session, even if the server has no logout route.
        }
        accessToken = nil
        username = ""
        errorMessage = nil
    }
}
