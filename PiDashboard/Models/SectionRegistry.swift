import Foundation

/// Registry of enabled dashboard sections.
/// Add/remove/reorder sections here.
enum SectionRegistry {
    static let enabledSections: [String] = [
        "todo",
        "grocery",
        "reminders",
        "activity",
    ]

    static func renderer(for sectionID: String) -> DashboardSectionRenderer {
        DefaultSectionRenderer(sectionID: sectionID)
    }
}
