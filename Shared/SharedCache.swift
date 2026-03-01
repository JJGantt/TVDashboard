import Foundation

final class SharedCache {
    static let shared = SharedCache()

    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: PiConstants.appGroupID)
    }

    func saveDashboard(_ response: DashboardResponse) {
        guard let data = try? JSONEncoder().encode(response) else { return }
        defaults?.set(data, forKey: PiConstants.dashboardCacheKey)
    }

    func loadDashboard() -> DashboardResponse? {
        guard let data = defaults?.data(forKey: PiConstants.dashboardCacheKey) else { return nil }
        return try? JSONDecoder().decode(DashboardResponse.self, from: data)
    }
}
