import Foundation

actor PiAPIClient {
    static let shared = PiAPIClient()

    func fetchDashboard() async throws -> DashboardResponse {
        // Try local IP first, then Tailscale
        for baseURL in [PiConstants.localBaseURL, PiConstants.tailscaleBaseURL] {
            guard let url = URL(string: "\(baseURL)/tv/dashboard") else { continue }
            var request = URLRequest(url: url)
            request.timeoutInterval = PiConstants.requestTimeout
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    continue
                }
                return try JSONDecoder().decode(DashboardResponse.self, from: data)
            } catch {
                continue
            }
        }
        throw PiError.serverError
    }
}

enum PiError: LocalizedError {
    case serverError

    var errorDescription: String? {
        "Could not reach Pi"
    }
}
