import Foundation

protocol NetworkProtocol {
    func fetch<Response: Decodable>(_ request: URLRequest) async throws -> Response
    func fetchData(_ request: URLRequest) async throws -> Data
}

extension NetworkProtocol {
    func fetch<Response: Decodable>(_ endpoint: APIEndpoint, baseURL: URL) async throws -> Response {
        try await fetch(endpoint.request(baseURL: baseURL))
    }

    func fetchData(_ endpoint: APIEndpoint, baseURL: URL) async throws -> Data {
        try await fetchData(endpoint.request(baseURL: baseURL))
    }
}

enum ServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case clientError(Int)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The request URL is invalid."
        case .invalidResponse: "The server returned an invalid response."
        case let .clientError(code): "The request failed with HTTP status \(code)."
        case let .serverError(code): "The server failed with HTTP status \(code)."
        }
    }
}
