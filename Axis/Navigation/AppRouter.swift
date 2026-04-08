import Foundation
import SwiftUI

/// Lightweight router for deep links from notifications and Universal Links.
///
/// Supported URLs:
///   axis://situation
///   axis://thread          (or axis://thread?id=...)
///   axis://meeting/{id}
///   axis://brief
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    enum Route: Equatable {
        case situation
        case thread(id: String?, prefill: Bool)
        case meeting(id: String)
        case brief
    }

    @Published var pendingRoute: Route?

    private init() {}

    nonisolated func open(_ url: URL?) {
        guard let url else { return }
        Task { @MainActor in self.handle(url) }
    }

    func handle(_ url: URL) {
        guard url.scheme == "axis" else { return }
        let host = url.host ?? ""
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        switch host {
        case "situation":
            pendingRoute = .situation
        case "thread":
            let id = queryItems.first(where: { $0.name == "id" })?.value
            let prefill = queryItems.first(where: { $0.name == "prefill" })?.value == "1"
            pendingRoute = .thread(id: id, prefill: prefill)
        case "meeting":
            if let id = pathComponents.first {
                pendingRoute = .meeting(id: id)
            }
        case "brief":
            pendingRoute = .brief
        default:
            print("[AppRouter] unknown deep link: \(url)")
        }
    }
}
