import Foundation

final class NetworkManager: NetworkProtocol {
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    init(urlSession: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func fetch<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let data = try await fetchData(request)
        return try decoder.decode(Response.self, from: data)
    }

    func fetchData(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await urlSession.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw ServiceError.invalidResponse }
        guard (200..<300).contains(response.statusCode) else {
            if (400..<500).contains(response.statusCode) { throw ServiceError.clientError(response.statusCode) }
            throw ServiceError.serverError(response.statusCode)
        }
        return data
    }
}
