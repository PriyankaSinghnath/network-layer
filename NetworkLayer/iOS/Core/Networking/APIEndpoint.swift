import Foundation

/// API routes and their typed request models.
enum APIEndpoint {
    case login(LoginRequestModel)
    case signup(SignupRequestModel)
    case refreshToken(RefreshTokenRequestModel)
    case dashboard(DashboardRequestModel)
    case logout(LogoutRequestModel)
    case productList(ProductListRequestModel)
    case getProduct(GetProductRequestModel)
    case deleteProduct(DeleteProductRequestModel)
    case addProduct(AddProductRequestModel)
    case updateProduct(UpdateProductRequestModel)

    private var configuration: EndpointConfiguration {
        switch self {
        case let .login(model):
            EndpointConfiguration(path: "auth/login", method: .post, requestModel: AnyEncodable(model))
        case let .signup(model):
            EndpointConfiguration(path: "users", method: .post, requestModel: AnyEncodable(model))
        case let .refreshToken(model):
            EndpointConfiguration(path: "auth/refresh", method: .post, requestModel: AnyEncodable(model))
        case let .dashboard(model):
            EndpointConfiguration(path: "dashboard/\(model.userId)")
        case let .logout(model):
            EndpointConfiguration(path: "auth/logout", method: .post, requestModel: AnyEncodable(model))
        case let .productList(model):
            EndpointConfiguration(path: "products", queryItems: model.queryItems)
        case let .getProduct(model):
            EndpointConfiguration(path: "products/\(model.id)")
        case let .deleteProduct(model):
            EndpointConfiguration(path: "products/\(model.id)", method: .delete)
        case let .addProduct(model):
            EndpointConfiguration(path: "products", method: .post, requestModel: AnyEncodable(model))
        case let .updateProduct(model):
            EndpointConfiguration(
                path: "products/\(model.id)",
                method: .put,
                requestModel: AnyEncodable(model)
            )
        }
    }

    func request(baseURL: URL) throws -> URLRequest {
        let endpoint = configuration
        let path = endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
            throw ServiceError.invalidURL
        }
        components.queryItems = (components.queryItems ?? []) + endpoint.queryItems
        guard let url = components.url else { throw ServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = try endpoint.requestModel.map { try JSONEncoder().encode($0) }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.requestModel != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        endpoint.headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

private struct EndpointConfiguration {
    let path: String
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var requestModel: AnyEncodable?
}

enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
    case head = "HEAD", options = "OPTIONS", trace = "TRACE", connect = "CONNECT"
}

struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void

    init<Value: Encodable>(_ value: Value) {
        encodeValue = value.encode(to:)
    }

    func encode(to encoder: Encoder) throws {
        try encodeValue(encoder)
    }
}
