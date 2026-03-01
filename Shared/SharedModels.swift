import Foundation

struct DashboardResponse: Codable {
    let sections: [SectionData]
    let generated: String
}

struct SectionData: Codable, Identifiable {
    let id: String
    let title: String
    let items: [ItemData]
}

struct ItemData: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let imageURL: String

    var fullImageURL: String {
        // Will be resolved at runtime with the correct base URL
        imageURL
    }
}
