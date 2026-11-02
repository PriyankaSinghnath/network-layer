import Combine
import Foundation

@MainActor
final class ProductViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let manager: APIManager

    init(manager: APIManager) {
        self.manager = manager
    }

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = ProductListRequestModel(limit: 20)
            let products = try await manager.productList(requestModel: request)
            try Task.checkCancellation()
            self.products = products
        } catch is CancellationError {
            // A disappeared view cancels its task; no error needs to be shown.
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
