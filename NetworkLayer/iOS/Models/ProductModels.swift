import Foundation

struct Product: Decodable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
}

struct ProductListRequestModel {
    let limit: Int

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "limit", value: String(limit))]
    }
}

struct GetProductRequestModel {
    let id: Int
}

struct DeleteProductRequestModel {
    let id: Int
}

struct AddProductRequestModel: Encodable {
    let title: String
    let price: Double
    let description: String
    let image: String
    let category: String
}

struct UpdateProductRequestModel: Encodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let image: String
    let category: String
}
