import Foundation

struct LoginRequestModel: Encodable {
    let username: String
    let password: String
}

struct SignupRequestModel: Encodable {
    let email: String
    let username: String
    let password: String
}

struct RefreshTokenRequestModel: Encodable {
    let refreshToken: String
}

struct LogoutRequestModel: Encodable {}

struct LoginResponse: Decodable {
    let token: String
}

struct SignupResponse: Decodable {
    let id: Int
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
}
