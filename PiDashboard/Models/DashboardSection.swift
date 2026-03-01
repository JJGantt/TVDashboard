import Foundation

/// Protocol for section renderers — allows adding new section types easily.
protocol DashboardSectionRenderer {
    var sectionID: String { get }
    func items(from data: SectionData) -> [ItemData]
}

/// Default renderer that passes items through unchanged.
struct DefaultSectionRenderer: DashboardSectionRenderer {
    let sectionID: String

    func items(from data: SectionData) -> [ItemData] {
        data.items
    }
}
