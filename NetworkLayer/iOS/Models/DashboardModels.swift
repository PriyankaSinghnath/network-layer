import Foundation

struct DashboardRequestModel {
    let userId: String
}

struct DashboardResponse: Decodable {
    let products: [Product]?
}
