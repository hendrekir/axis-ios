import Foundation
import ClerkKit

/// Handles all network communication with the Axis backend on Railway.
final class APIService {
    static let shared = APIService()

    private let baseURL = URL(string: "https://web-production-32f5d.up.railway.app")!
    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Auth header

    /// Gets the current auth token. On device: fresh Clerk token. On simulator: dev token from Keychain.
    private func getAuthToken() async -> String? {
        #if targetEnvironment(simulator)
        return KeychainService.shared.get(.clerkJWT)
        #else
        // Get a fresh token from Clerk (auto-refreshes if near expiry)
        return try? await Clerk.shared.auth.getToken()
        #endif
    }

    private func authorizedRequest(for endpoint: String, method: String = "GET") async -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = await getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // MARK: - Generic request

    func request<T: Decodable>(_ endpoint: String, method: String = "GET", body: Encodable? = nil) async throws -> T {
        var req = await authorizedRequest(for: endpoint, method: method)

        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }

        return try decoder.decode(T.self, from: data)
    }

    func requestVoid(_ endpoint: String, method: String = "POST", body: Encodable? = nil) async throws {
        var req = await authorizedRequest(for: endpoint, method: method)

        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
    }
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code, _):
            return "Server error (\(code))"
        case .unauthorized:
            return "Not authenticated"
        }
    }
}
