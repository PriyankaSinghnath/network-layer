import Foundation

final class APIManager {
    private let networkManager: any NetworkProtocol
    private let baseURL: URL

    init(
        networkManager: any NetworkProtocol,
        baseURL: URL = URL(string: "https://fakestoreapi.com")!
    ) {
        self.networkManager = networkManager
        self.baseURL = baseURL
    }

    func login(requestModel: LoginRequestModel) async throws -> LoginResponse {
        try await networkManager.fetch(.login(requestModel), baseURL: baseURL)
    }

    func signup(requestModel: SignupRequestModel) async throws -> SignupResponse {
        try await networkManager.fetch(.signup(requestModel), baseURL: baseURL)
    }

    func refreshToken(requestModel: RefreshTokenRequestModel) async throws -> RefreshTokenResponse {
        try await networkManager.fetch(.refreshToken(requestModel), baseURL: baseURL)
    }

    func dashboard(requestModel: DashboardRequestModel) async throws -> DashboardResponse {
        try await networkManager.fetch(.dashboard(requestModel), baseURL: baseURL)
    }

    func logout(requestModel: LogoutRequestModel) async throws {
        _ = try await networkManager.fetchData(.logout(requestModel), baseURL: baseURL)
    }

    func productList(requestModel: ProductListRequestModel) async throws -> [Product] {
        try await networkManager.fetch(.productList(requestModel), baseURL: baseURL)
    }

    func getProduct(requestModel: GetProductRequestModel) async throws -> Product {
        try await networkManager.fetch(.getProduct(requestModel), baseURL: baseURL)
    }

    func deleteProduct(requestModel: DeleteProductRequestModel) async throws {
        _ = try await networkManager.fetchData(.deleteProduct(requestModel), baseURL: baseURL)
    }

    func addProduct(requestModel: AddProductRequestModel) async throws -> Product {
        try await networkManager.fetch(.addProduct(requestModel), baseURL: baseURL)
    }

    func updateProduct(requestModel: UpdateProductRequestModel) async throws -> Product {
        try await networkManager.fetch(.updateProduct(requestModel), baseURL: baseURL)
    }
}
