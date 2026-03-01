import Foundation

enum PiConstants {
    static var localBaseURL: String {
        let host = Bundle.main.infoDictionary?["PILocalHost"] as? String ?? ""
        return "http://\(host)"
    }
    static var tailscaleBaseURL: String {
        let host = Bundle.main.infoDictionary?["PITailscaleHost"] as? String ?? ""
        return "http://\(host)"
    }
    static let appGroupID = "group.com.jaredgantt.pidashboard"
    static let urlScheme = "pidashboard"
    static let dashboardCacheKey = "cachedDashboard"
    static let refreshInterval: TimeInterval = 60
    static let requestTimeout: TimeInterval = 10
}
