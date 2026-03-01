import Foundation
import Combine

@MainActor
final class DashboardStore: ObservableObject {
    @Published var sections: [SectionData] = []
    @Published var lastUpdated: String = ""
    @Published var isLoading = false
    @Published var isConnected = true
    @Published var errorMessage: String?

    private var refreshTask: Task<Void, Never>?

    func startAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(for: .seconds(PiConstants.refreshInterval))
            }
        }
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await PiAPIClient.shared.fetchDashboard()
            sections = response.sections
            lastUpdated = response.generated
            isConnected = true
            errorMessage = nil
            SharedCache.shared.saveDashboard(response)
        } catch {
            isConnected = false
            errorMessage = error.localizedDescription
            // Load from cache
            if let cached = SharedCache.shared.loadDashboard() {
                sections = cached.sections
                lastUpdated = cached.generated
            }
        }
    }
}
