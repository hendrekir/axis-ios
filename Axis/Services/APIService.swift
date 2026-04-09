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

        // Share API base URL with widget extension.
        AppGroupBridge.setBaseURL(baseURL.absoluteString)
    }

    // MARK: - Auth header

    private func authorizedRequest(for endpoint: String, method: String = "GET") async -> URLRequest {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        #if targetEnvironment(simulator)
        // Simulator: no JWT, use dev bypass header instead
        request.setValue("true", forHTTPHeaderField: "X-Dev-Simulator")
        #else
        // Device: prefer dev login token if present (avoids Clerk getToken
        // returning empty/invalid when no Clerk session exists).
        // Fall back to live Clerk JWT for real sign-in sessions.
        if let devToken = KeychainService.shared.get(.clerkJWT), !devToken.isEmpty {
            request.setValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            AppGroupBridge.setToken(devToken)
        } else if let token = try? await Clerk.shared.auth.getToken(), let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            AppGroupBridge.setToken(token)
        }
        #endif

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

        print("[API] \(method) \(endpoint) → \(http.statusCode)")

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

        print("[API] \(method) \(endpoint) → \(http.statusCode)")

        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpError(statusCode: http.statusCode, data: data)
        }
    }

    // MARK: - Notification action endpoints

    private struct DeviceTokenBody: Encodable {
        let token: String
        let platform: String = "ios"
    }

    private struct SnoozeBody: Encodable {
        let hours: Int
    }

    func registerDeviceToken(_ token: String) async throws {
        try await requestVoid("/me/device-token", method: "POST", body: DeviceTokenBody(token: token))
    }

    func completeTopSignal() async throws {
        try await requestVoid("/signal/top/complete", method: "POST")
    }

    func snoozeTopSignal(hours: Int) async throws {
        try await requestVoid("/signal/top/snooze", method: "POST", body: SnoozeBody(hours: hours))
    }

    func dismissTopSignal() async throws {
        try await requestVoid("/signal/top/dismiss", method: "POST")
    }

    func sendPendingDraft() async throws {
        try await requestVoid("/gmail/send", method: "POST")
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
